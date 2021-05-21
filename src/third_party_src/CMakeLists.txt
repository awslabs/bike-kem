## Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
## SPDX-License-Identifier: Apache-2.0"

FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

if(USE_SHA3_AND_SHAKE)
  target_sources(${PROJECT_NAME}
    PRIVATE
      ${CMAKE_CURRENT_LIST_DIR}/fips202.c)
endif()
