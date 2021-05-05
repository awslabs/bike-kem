## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: Apache-2.0"

FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

target_sources(${PROJECT_NAME}
        PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/sampling.c
        ${CMAKE_CURRENT_LIST_DIR}/sampling_portable.c
    
        ${HEADERS}
)

if(X86_64)
  target_sources(${PROJECT_NAME}
          PRIVATE
            ${CMAKE_CURRENT_LIST_DIR}/sampling_avx2.c
            ${CMAKE_CURRENT_LIST_DIR}/sampling_avx512.c)
endif()

if(USE_SHA3_AND_SHAKE)
    # TODO: clarify the SHA3 situation and rename sha.c, fix identation
    target_sources(${PROJECT_NAME}
            PRIVATE
            ${CMAKE_CURRENT_LIST_DIR}/shake_prf.c)
else()
    target_sources(${PROJECT_NAME}
            PRIVATE
            ${CMAKE_CURRENT_LIST_DIR}/aes_ctr_prf.c)
endif()

if(STANDALONE_IMPL AND NOT USE_SHA3_AND_SHAKE)
    target_sources(${PROJECT_NAME}
            PRIVATE
            ${CMAKE_CURRENT_LIST_DIR}/sha.c
            ${CMAKE_CURRENT_LIST_DIR}/aes.c)
endif()