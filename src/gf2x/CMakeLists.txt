# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

target_sources(${PROJECT_NAME}
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul.c
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_mul${SUFMUL}.c
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_inv.c
    ${CMAKE_CURRENT_LIST_DIR}/gf2x_ksqr${SUF}.c
    
    ${HEADERS}
)