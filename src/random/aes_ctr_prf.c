/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0"
 *
 * Written by Nir Drucker, Shay Gueron and Dusan Kostic,
 * AWS Cryptographic Algorithms Group.
 */

#include "prf_internal.h"
#include "utilities.h"

ret_t init_prf_state(OUT aes_ctr_prf_state_t *s, IN size_t max_num_invocations,
                     IN const seed_t *seed)
{
  if(0 == max_num_invocations) {
    BIKE_ERROR(E_AES_CTR_PRF_INIT_FAIL);
  }

  // Set the key schedule (from seed).
  // Make sure the size matches the AES256 key size.
  DEFER_CLEANUP(aes256_key_t key, aes256_key_cleanup);

  bike_static_assert(sizeof(*seed) == sizeof(key.raw), seed_size_equals_ky_size);
  bike_memcpy(key.raw, seed->raw, sizeof(key.raw));

  GUARD(aes256_key_expansion(&s->ks, &key));

  // Initialize buffer and counter
  s->ctr.u.qw[0]    = 0;
  s->ctr.u.qw[1]    = 0;
  s->buffer.u.qw[0] = 0;
  s->buffer.u.qw[1] = 0;

  s->curr_pos_in_buffer = AES256_BLOCK_BYTES;
  s->rem_invocations    = max_num_invocations;

  DMSG("    Init aes_prf_ctr state:\n");
  DMSG("      s.curr_pos_in_buffer = %d\n", s->curr_pos_in_buffer);
  DMSG("      s.rem_invocations = %u\n", s->rem_invocations);

  return SUCCESS;
}

_INLINE_ ret_t perform_aes(OUT uint8_t *ct, IN OUT aes_ctr_prf_state_t *s)
{
  // Ensure that the CTR is large enough
  bike_static_assert(
    ((sizeof(s->ctr.u.qw[0]) == 8) && (BIT(33) >= MAX_PRF_INVOCATION)),
    ctr_size_is_too_small);

  if(0 == s->rem_invocations) {
    BIKE_ERROR(E_AES_OVER_USED);
  }

  GUARD(aes256_enc(ct, s->ctr.u.bytes, &s->ks));

  s->ctr.u.qw[0]++;
  s->rem_invocations--;

  return SUCCESS;
}

ret_t get_prf_output(OUT uint8_t *out, IN OUT aes_ctr_prf_state_t *s,
                     IN size_t len)
{
  // When Len is smaller then use what's left in the buffer,
  // there is no need for additional AES invocations.
  if((len + s->curr_pos_in_buffer) <= AES256_BLOCK_BYTES) {
    bike_memcpy(out, &s->buffer.u.bytes[s->curr_pos_in_buffer], len);
    s->curr_pos_in_buffer += len;

    return SUCCESS;
  }

  // If s.curr_pos_in_buffer != AES256_BLOCK_BYTES then copy what's left
  // in the buffer.
  uint32_t idx = AES256_BLOCK_BYTES - s->curr_pos_in_buffer;
  bike_memcpy(out, &s->buffer.u.bytes[s->curr_pos_in_buffer], idx);

  // Init s.curr_pos_in_buffer
  s->curr_pos_in_buffer = 0;

  // Copy full AES blocks
  while((len - idx) >= AES256_BLOCK_BYTES) {
    GUARD(perform_aes(&out[idx], s));
    idx += AES256_BLOCK_BYTES;
  }

  GUARD(perform_aes(s->buffer.u.bytes, s));

  // Copy the tail
  s->curr_pos_in_buffer = len - idx;
  bike_memcpy(&out[idx], s->buffer.u.bytes, s->curr_pos_in_buffer);

  return SUCCESS;
}

void clean_prf_state(IN OUT aes_ctr_prf_state_t *s)
{
  aes256_free_ks(&s->ks);
  secure_clean((uint8_t *)s, sizeof(*s));
}
