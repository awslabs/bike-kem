## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: Apache-2.0"

FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

target_sources(${PROJECT_NAME}
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/aes_ctr_prf.c 
    ${CMAKE_CURRENT_LIST_DIR}/sampling.c 
    ${CMAKE_CURRENT_LIST_DIR}/sampling${SUF}.c
    
    ${HEADERS}
)

if(NOT DEFINED USE_OPENSSL)
  target_sources(${PROJECT_NAME}
    PRIVATE
      ${CMAKE_CURRENT_LIST_DIR}/aes.c
      ${CMAKE_CURRENT_LIST_DIR}/sha.c      
  )
endif()
