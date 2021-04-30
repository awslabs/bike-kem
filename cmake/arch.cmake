# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "^(x86_64|amd64|AMD64)$")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DX86_64")
  set(X86_64 1)
elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "^(x86)$")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DX86")
  set(X86 1)
elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "^(aarch64|arm64|arm64e)$")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DAARCH64 -DNEON_SUPPORT")
  set(AARCH64 1)
else()
  message(FATAL_ERROR "Only X86_64/X86/AARCH64 platforms are supported")
endif()

# Only little endian systems are supported
try_run(RUN_RESULT COMPILE_RESULT
  "${CMAKE_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/cmake/test_endianess.c"
  COMPILE_DEFINITIONS "-Werror -Wall -Wpedantic"
  OUTPUT_VARIABLE OUTPUT
)

if((NOT ${COMPILE_RESULT}) OR (NOT RUN_RESULT EQUAL 0))
  message(FATAL "Only little endian systems are supported")
endif()
