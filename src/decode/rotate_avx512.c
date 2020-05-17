/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0"
 *
 * Written by Nir Drucker, Shay Gueron and Dusan Kostic,
 * AWS Cryptographic Algorithms Group.
 *
 * The rotation functions are based on the Barrel shifter described in [1]
 * and some modifed snippet from [2]
 * [1] Chou, T.: QcBits: Constant-Time Small-Key Code-Based Cryptography.
 *     In: Gier-lichs, B., Poschmann, A.Y. (eds.) Cryptographic Hardware
 *     and Embedded Systems– CHES 2016. pp. 280–300. Springer Berlin Heidelberg,
 *     Berlin, Heidelberg (2016)
 *
 * [2] Guimarães, Antonio, Diego F Aranha, and Edson Borin. 2019.
 *     “Optimized Implementation of QC-MDPC Code-Based Cryptography.”
 *     Concurrency and Computation: Practice and Experience 31 (18):
 *     e5089. https://doi.org/10.1002/cpe.5089.
 */

#include "decode.h"
#include "utilities.h"

#define R_ZMM_HALF_LOG2 UPTOPOW2(R_ZMM / 2)

_INLINE_ void
rotate512_big(OUT syndrome_t *out, IN const syndrome_t *in, size_t zmm_num)
{
  // For preventing overflows (comparison in bytes)
  bike_static_assert(sizeof(*out) >
                       (BYTES_IN_ZMM * (R_ZMM + (2 * R_ZMM_HALF_LOG2))),
                     rotr_big_err);
  *out = *in;

  for(uint32_t idx = R_ZMM_HALF_LOG2; idx >= 1; idx >>= 1) {
    const uint8_t mask = secure_l32_mask(zmm_num, idx);
    zmm_num            = zmm_num - (idx & mask);

    for(size_t i = 0; i < (R_ZMM + idx); i++) {
      const __m512i a = LOAD(&out->qw[8 * (i + idx)]);
      MSTORE(&out->qw[8 * i], mask, a);
    }
  }
}

// The rotate512_small function is a derivative of the code described in [1]
_INLINE_ void
rotate512_small(OUT syndrome_t *out, IN const syndrome_t *in, size_t bitscount)
{
  __m512i       previous     = SET_ZERO;
  const int     count64      = (int)bitscount & 0x3f;
  const __m512i count64_512  = SET1_I64(count64);
  const __m512i count64_512r = SET1_I64((int)64 - count64);

  const __m512i num_full_qw = SET1_I64(bitscount >> 6);
  const __m512i one         = SET1_I64(1);
  __m512i       a0, a1;

  __m512i idx = SET_I64(7, 6, 5, 4, 3, 2, 1, 0);

  // Positions above 7 are taken from the second register in
  // _mm512_permutex2var_epi64
  idx          = ADD_I64(idx, num_full_qw);
  __m512i idx1 = ADD_I64(idx, one);

  for(int i = R_ZMM; i >= 0; i--) {
    // Load the next 512 bits
    const __m512i in512 = LOAD(&in->qw[8 * i]);

    // Rotate the current and previous 512 registers so that their quadwords
    // would be in the right positions.
    a0 = PERMX2VAR_I64(in512, idx, previous);
    a1 = PERMX2VAR_I64(in512, idx1, previous);

    a0 = SRLV_I64(a0, count64_512);
    a1 = SLLV_I64(a1, count64_512r);

    // Shift less than 64 (quadwords internal)
    const __m512i out512 = a0 | a1;

    // Store the rotated value
    STORE(&out->qw[8 * i], out512);
    previous = in512;
  }
}

void rotate_right(OUT syndrome_t *out,
                  IN const syndrome_t *in,
                  IN const uint32_t    bitscount)
{
  // 1) Rotate in granularity of 512 bits blocks, using ZMMs
  rotate512_big(out, in, (bitscount / BITS_IN_ZMM));
  // 2) Rotate in smaller granularity (less than 512 bits), using ZMMs
  rotate512_small(out, out, (bitscount % BITS_IN_ZMM));
}
