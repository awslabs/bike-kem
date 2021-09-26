# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

target_sources(${PROJECT_NAME}
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul.c
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul_portable.c
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul_base_portable.c
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_inv.c
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_ksqr_portable.c
    
    ${HEADERS}
)

if(X86_64)
  target_sources(${PROJECT_NAME}
    PRIVATE
      ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul_avx2.c
      ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul_avx512.c
      ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul_base_pclmul.c
      ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul_base_vpclmul.c
      ${CMAKE_CURRENT_LIST_DIR}/gf2x_ksqr_avx2.c
      ${CMAKE_CURRENT_LIST_DIR}/gf2x_ksqr_avx512.c)
endif()