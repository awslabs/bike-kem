/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0"
 *
 * Written by Nir Drucker, Shay Gueron and Dusan Kostic,
 * AWS Cryptographic Algorithms Group.
 */

#include <assert.h>

#include "utilities.h"
#include "sampling_internal.h"

#define MAX_WLIST_SIZE (MAX_RAND_INDICES_T)

void secure_set_bits_port(OUT pad_r_t *   r,
                          IN const size_t first_pos,
                          IN const idx_t *wlist,
                          IN const size_t w_size)
{
  assert(w_size <= MAX_WLIST_SIZE);

  // Ideally we would like to cast r.val but it is not guaranteed to be aligned
  // as the entire pad_r_t structure. Thus, we assert that the position of val
  // is at the beginning of r.
  bike_static_assert(offsetof(pad_r_t, val) == 0, val_wrong_pos_in_pad_r_t);
  uint64_t *a64 = (uint64_t *)r;
  uint64_t  val, mask;

  // The size of wlist can be either D or T. So, we set it to max(D, T)
  size_t pos_qw[MAX_WLIST_SIZE];
  size_t pos_bit[MAX_WLIST_SIZE];

  // Identify the QW position of every value, and the bit position inside this QW.
  for(size_t i = 0; i < w_size; i++) {
    int32_t w  = wlist[i] - first_pos;
    pos_qw[i]  = (w >> 6);
    pos_bit[i] = BIT(w & MASK(6));
  }

  // Fill each QW in constant time
  for(size_t i = 0; i < (sizeof(*r) / sizeof(uint64_t)); i++) {
    val = 0;
    for(size_t j = 0; j < w_size; j++) {
      mask = (-1ULL) + (!secure_cmp32(pos_qw[j], i));
      val |= (pos_bit[j] & mask);
    }
    a64[i] = val;
  }
}

#if defined(UNIFORM_SAMPLING)
ret_t sample_error_vec_indices_port(OUT idx_t *out,
                                    IN OUT prf_state_t *prf_state)
{
  // To generate T indices in constant-time, i.e. without rejection sampling,
  // we generate MAX_RAND_INDICES_T random values with the appropriate bit
  // length (the bit size of N) and in constant time copy the first T valid
  // indices to the output.

  size_t ctr = 0; // Current number of valid and distinct indices.
  const idx_t bit_mask = MASK(bit_scan_reverse_vartime(2*R_BITS));

  // Label all output elements as invalid.
  bike_memset((uint8_t*)out, 0xff, T * sizeof(idx_t));

  // Generate MAX_RAND_INDICES_T random values.
  for (size_t i = 0; i < MAX_RAND_INDICES_T; i++) {
    // Generate random index with the required bit length.
    uint32_t idx;
    GUARD(get_prf_output((uint8_t*)&idx, prf_state, sizeof(idx_t)));
    idx &= bit_mask;

    // Loop over the output array to determine if |idx| is a duplicate,
    // and store it in the lcoation pointed to by |ctr|.
    uint32_t is_dup = 0;
    for (size_t j = 0; j < T; j++) {
      is_dup |= secure_cmp32(idx, out[j]);

      // Set |mask| to 0 if |ctr| != |j|, to all ones otherwise.
      uint32_t mask = -secure_cmp32(j, ctr);
      // Write |idx| to out if |ctr| == |j|.
      out[j] = (~mask & out[j]) | (mask & idx);
    }

    // Check if |idx| is a valid index (< N) and increase the counter
    // only if |idx| is valid and it is not a duplicate.
    uint32_t is_valid = secure_l32(idx, 2*R_BITS);
    ctr += ((1 - is_dup) & is_valid);
  }

  return SUCCESS;
}
#endif
