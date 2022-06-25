/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0"
 *
 * Written by Nir Drucker, Shay Gueron and Dusan Kostic,
 * AWS Cryptographic Algorithms Group.
 */

#pragma once

#include "cpu_features.h"
#include "defs.h"
#include "types.h"
#include "prf_internal.h"

// Value used to denote an invalid index for ther error vector.
#define IDX_INVALID_VAL (0xffffffff)

void secure_set_bits_port(OUT pad_r_t *r,
                          IN size_t    first_pos,
                          IN const idx_t *wlist,
                          IN size_t       w_size);

ret_t sample_error_vec_indices_port(OUT idx_t *out,
                                    IN OUT prf_state_t *prf_state);

#if defined(X86_64)
void secure_set_bits_avx2(OUT pad_r_t *r,
                          IN size_t    first_pos,
                          IN const idx_t *wlist,
                          IN size_t       w_size);

void secure_set_bits_avx512(OUT pad_r_t *r,
                            IN size_t    first_pos,
                            IN const idx_t *wlist,
                            IN size_t       w_size);

ret_t sample_error_vec_indices_avx2(OUT idx_t *out,
                                    IN OUT prf_state_t *prf_state);
ret_t sample_error_vec_indices_avx512(OUT idx_t *out,
                                      IN OUT prf_state_t *prf_state);
#endif

typedef struct sampling_ctx_st {
  void (*secure_set_bits)(OUT pad_r_t *r,
                          IN size_t    first_pos,
                          IN const idx_t *wlist,
                          IN size_t       w_size);

  ret_t (*sample_error_vec_indices)(OUT idx_t *out,
                                    IN OUT prf_state_t *prf_state);
} sampling_ctx;

_INLINE_ void sampling_ctx_init(sampling_ctx *ctx)
{
#if defined(X86_64)
  if(is_avx512_enabled()) {
    ctx->secure_set_bits = secure_set_bits_avx512;
    ctx->sample_error_vec_indices = sample_error_vec_indices_avx512;
  } else if(is_avx2_enabled()) {
    ctx->secure_set_bits = secure_set_bits_avx2;
    ctx->sample_error_vec_indices = sample_error_vec_indices_avx2;
  } else
#endif
  {
    ctx->secure_set_bits = secure_set_bits_port;
    ctx->sample_error_vec_indices = sample_error_vec_indices_port;
  }
}
