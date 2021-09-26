# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

target_sources(${PROJECT_NAME}
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/decode.c
    ${CMAKE_CURRENT_LIST_DIR}/decode_portable.c
    ${HEADERS}
)

if(X86_64)
  target_sources(${PROJECT_NAME}
    PRIVATE
      ${CMAKE_CURRENT_LIST_DIR}/decode_avx2.c
      ${CMAKE_CURRENT_LIST_DIR}/decode_avx512.c)
endif()
