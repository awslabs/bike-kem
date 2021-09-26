# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

target_sources(${PROJECT_NAME}
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/kem.c
)

add_subdirectory(common)
add_subdirectory(decode)
add_subdirectory(gf2x)
add_subdirectory(random)
add_subdirectory(third_party_src)
