/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0"
 *
 * Written by Nir Drucker, Shay Gueron and Dusan Kostic,
 * AWS Cryptographic Algorithms Group.
 */

#include <assert.h>

#include "utilities.h"
#include "sampling_internal.h"

#define AVX512_INTERNAL
#include "x86_64_intrinsic.h"

// For improved performance, we process NUM_ZMMS amount of data in parallel.
#define NUM_ZMMS    (8)
#define ZMMS_QWORDS (QWORDS_IN_ZMM * NUM_ZMMS)

void secure_set_bits_avx512(OUT pad_r_t *   r,
                            IN const size_t first_pos,
                            IN const idx_t *wlist,
                            IN const size_t w_size)
{
  // The function assumes that the size of r is a multiple
  // of the cumulative size of used ZMM registers.
  assert((sizeof(*r) / sizeof(uint64_t)) % ZMMS_QWORDS == 0);

  // va vectors hold the bits of the output array "r"
  // va_pos_qw vectors hold the qw position indices of "r"
  // The algorithm works as follows:
  //   1. Initialize va_pos_qw with starting positions of qw's of "r"
  //      va_pos_qw = (7, 6, 5, 4, 3, 2, 1, 0);
  //   2. While the size of "r" is not exceeded:
  //   3.   For each w in wlist:
  //   4.     Compare the pos_qw of w with positions in va_pos_qw
  //          and for the position which is equal set the appropriate
  //          bit in va vector.
  //   5.   Set va_pos_qw to the next qw positions of "r"
  __m512i  va[NUM_ZMMS], va_pos_qw[NUM_ZMMS];
  __m512i  w_pos_qw, w_pos_bit, one, inc;
  __mmask8 va_mask;

  uint64_t *r64 = (uint64_t *)r;

  one = SET1_I64(1);
  inc = SET1_I64(QWORDS_IN_ZMM);

  // 1. Initialize
  va_pos_qw[0] = SET_I64(7, 6, 5, 4, 3, 2, 1, 0);
  for(size_t i = 1; i < NUM_ZMMS; i++) {
    va_pos_qw[i] = ADD_I64(va_pos_qw[i - 1], inc);
  }

  // va_pos_qw vectors hold qw positions 0 .. (NUM_ZMMS * QWORDS_IN_ZMM - 1)
  // Therefore, we set the increment vector inc such that by adding it to
  // va_pos_qw vectors they hold the next ZMMS_QWORDS qw positions.
  inc = SET1_I64(ZMMS_QWORDS);

  for(size_t i = 0; i < (sizeof(*r) / sizeof(uint64_t)); i += ZMMS_QWORDS) {
    for(size_t va_iter = 0; va_iter < NUM_ZMMS; va_iter++) {
      va[va_iter] = SET_ZERO;
    }

    for(size_t w_iter = 0; w_iter < w_size; w_iter++) {
      int32_t w = wlist[w_iter] - first_pos;
      w_pos_qw  = SET1_I64(w >> 6);
      w_pos_bit = SLLI_I64(one, w & MASK(6));

      // 4. Compare the positions in va_pos_qw with w_pos_qw
      //    and set the appropriate bit in va
      for(size_t va_iter = 0; va_iter < NUM_ZMMS; va_iter++) {
        va_mask     = CMPMEQ_I64(va_pos_qw[va_iter], w_pos_qw);
        va[va_iter] = MOR_I64(va[va_iter], va_mask, va[va_iter], w_pos_bit);
      }
    }

    // 5. Set the va_pos_qw to the next qw positions of r
    //    and store the previously computed data in r
    for(size_t va_iter = 0; va_iter < NUM_ZMMS; va_iter++) {
      STORE(&r64[i + (va_iter * QWORDS_IN_ZMM)], va[va_iter]);
      va_pos_qw[va_iter] = ADD_I64(va_pos_qw[va_iter], inc);
    }
  }
}

// We need the list of indices to be a multiple of avx512 register.
#define WLIST_SIZE_ADJUSTED_T \
  (REG_DWORDS * DIVIDE_AND_CEIL(T, REG_DWORDS))

ret_t sample_error_vec_indices_avx512(OUT idx_t *out,
                                      IN OUT prf_state_t *prf_state)
{
  // To generate T indices in constant-time, i.e. without rejection sampling,
  // we generate MAX_RAND_INDICES_T random values with the appropriate bit
  // length (the bit size of N) and in constant time copy the first T valid
  // indices to the output.

  size_t ctr = 0; // Current number of valid and distinct indices.
  const idx_t bit_mask = MASK(bit_scan_reverse_vartime(2*R_BITS));

  idx_t wlist[WLIST_SIZE_ADJUSTED_T];
  // Label all indices as invalid.
  bike_memset((uint8_t*)wlist, 0xff, WLIST_SIZE_ADJUSTED_T * sizeof(idx_t));

  // Generate MAX_RAND_INDICES_T random values.
  for (size_t i = 0; i < MAX_RAND_INDICES_T; i++) {
    // Generate random index with the required bit length.
    uint32_t idx;
    GUARD(get_prf_output((uint8_t*)&idx, prf_state, sizeof(idx_t)));
    idx &= bit_mask;

    // Loop over the output array to determine if |idx| is a duplicate,
    // and store it in the lcoation pointed to by |ctr|.
    uint16_t is_dup = 0;
    REG_T vidx = SET1_I32(idx);
    REG_T vctr = SET1_I32(ctr);
    REG_T step = SET1_I32(16);
    REG_T tmp  = SET_I32(15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);

    for (size_t j = 0; j < WLIST_SIZE_ADJUSTED_T; j += REG_DWORDS) {

      REG_T vout = LOAD(&wlist[j]);
      is_dup |= CMPM_U32(vidx, vout, _MM_CMPINT_EQ);

      uint16_t write_mask = CMPM_U32(vctr, tmp, _MM_CMPINT_EQ);
      tmp = ADD_I32(tmp, step);

      MSTORE32(&wlist[j], write_mask, vidx);
    }

    // Check if |idx| is a valid index (< N) and increase the counter
    // only if |idx| is valid and it is not a duplicate.
    uint32_t is_valid = secure_l32(idx, 2*R_BITS);
    ctr += ((is_dup == 0) & is_valid);
  }

  // Copy the indices to the output.
  bike_memcpy((uint8_t*)out, (uint8_t*)wlist, T * sizeof(idx_t));

  return SUCCESS;
}

