/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0"
 *
 * Written by Nir Drucker, Shay Gueron and Dusan Kostic,
 * AWS Cryptographic Algorithms Group.
 */

#pragma once

#include "defs.h"
#include "error.h"
#include "types.h"

#if defined(USE_SHA3_AND_SHAKE)

#  include "fips202.h"

typedef struct shake256_prf_state_s {
  uint64_t s[25];
  uint8_t  buffer[SHAKE256_RATE];
  size_t   curr_pos_in_buffer;
  size_t   rem_invocations;
} shake256_prf_state_t;

typedef shake256_prf_state_t prf_state_t;

#else

#include "aes.h"

typedef struct aes_ctr_prf_state_s {
  uint128_t   ctr;
  uint128_t   buffer;
  aes256_ks_t ks;
  size_t      curr_pos_in_buffer;
  size_t      rem_invocations;
} aes_ctr_prf_state_t;

typedef aes_ctr_prf_state_t prf_state_t;

#endif

#define MAX_PRF_INVOCATION (MASK(32))

// Methods for interacting with the PRFs.
ret_t init_prf_state(OUT prf_state_t *s, IN size_t max_num_invocations,
                     IN const seed_t *seed);

ret_t get_prf_output(OUT uint8_t *out, IN OUT prf_state_t *s, IN size_t len);

void clean_prf_state(IN OUT prf_state_t *s);
