/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0"
 *
 * Written by Nir Drucker, Shay Gueron and Dusan Kostic,
 * AWS Cryptographic Algorithms Group.
 */

#include "cpu_features.h"
#include <stdint.h>
#include <stdio.h>

static uint32_t avx2_flag;
static uint32_t avx512_flag;
static uint32_t pclmul_flag;
static uint32_t vpclmul_flag;

uint32_t is_avx2_enabled(void) { return avx2_flag; }
uint32_t is_avx512_enabled(void) { return avx512_flag; }
uint32_t is_pclmul_enabled(void) { return pclmul_flag; }
uint32_t is_vpclmul_enabled(void) { return vpclmul_flag; }

#if defined(X86_64)

#  include <cpuid.h>

#  define EXTENDED_FEATURES_LEAF         7
#  define EXTENDED_FEATURES_SUBLEAF_ZERO 0

#  define EBX_BIT_AVX2    (1 << 5)
#  define EBX_BIT_AVX512  (1 << 16)
#  define ECX_BIT_VPCLMUL (1 << 10)
#  define ECX_BIT_PCLMUL  (1 << 1)

static uint32_t get_cpuid_count(uint32_t  leaf,
                                uint32_t  sub_leaf,
                                uint32_t *eax,
                                uint32_t *ebx,
                                uint32_t *ecx,
                                uint32_t *edx)
{
  /* 0x80000000 probes for extended cpuid info */
  uint32_t max_level = __get_cpuid_max(leaf & 0x80000000, 0);

  if(max_level == 0 || max_level < leaf) {
    return 0;
  }

  __cpuid_count(leaf, sub_leaf, *eax, *ebx, *ecx, *edx);
  return 1;
}

void cpu_features_init(void)
{
  uint32_t eax, ebx, ecx, edx;
  if(!get_cpuid_count(EXTENDED_FEATURES_LEAF, EXTENDED_FEATURES_SUBLEAF_ZERO,
                      &eax, &ebx, &ecx, &edx)) {
    return;
  }

  avx2_flag    = ebx & EBX_BIT_AVX2;
  avx512_flag  = ebx & EBX_BIT_AVX512;
  vpclmul_flag = ecx & ECX_BIT_VPCLMUL;

  if(!get_cpuid_count(1, EXTENDED_FEATURES_SUBLEAF_ZERO,
                      &eax, &ebx, &ecx, &edx)) {
    return;
  }
  pclmul_flag = ecx & ECX_BIT_PCLMUL;
}

#else // X86_64

void cpu_features_init(void)
{
  avx2_flag    = 0;
  avx512_flag  = 0;
  pclmul_flag  = 0;
  vpclmul_flag = 0;
}

#endif
