# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

if(USE_NIST_RAND)
  FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

  target_sources(bike-test
    PRIVATE
      ${CMAKE_CURRENT_LIST_DIR}/FromNIST/rng.c 
      ${CMAKE_CURRENT_LIST_DIR}/FromNIST/PQCgenKAT_kem.c
      
      ${HEADERS}
  )
else()
  target_sources(bike-test
    PRIVATE
      ${CMAKE_CURRENT_LIST_DIR}/main_test.c
  )
endif()
