# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

if(CMAKE_C_COMPILER_ID MATCHES "Clang")
  set(CLANG 1)
else()
  set(CLANG 0)
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ggdb -fPIC -std=c99")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden -Wall -Wextra -Werror -Wpedantic")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wunused -Wcomment -Wchar-subscripts -Wuninitialized -Wshadow")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wwrite-strings -Wformat-security -Wcast-qual -Wunused-result")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -funroll-loops")

if(X86_64)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64 -mno-red-zone")
elseif(X86)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32 -mno-red-zone")
endif()

# Avoiding GCC 4.8 bug
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-missing-braces -Wno-missing-field-initializers")

if(NOT DEFINED VERBOSE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wcast-align")
endif()

if(MSAN)
  if(NOT CLANG)
    message(FATAL_ERROR "Cannot enable MSAN unless using Clang")
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=memory -fsanitize-memory-track-origins -fno-omit-frame-pointer")
endif()

if(ASAN)
  if(NOT CLANG)
    message(FATAL_ERROR "Cannot enable ASAN unless using Clang")
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fsanitize-address-use-after-scope -fno-omit-frame-pointer")
endif()

if(TSAN)
  if(NOT CLANG)
    message(FATAL_ERROR "Cannot enable TSAN unless using Clang")
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=thread")
endif()

if(UBSAN)
  if(NOT CLANG)
    message(FATAL_ERROR "Cannot enable UBSAN unless using Clang")
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=undefined")
endif()

if(RDTSC)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DRDTSC")
endif()

if(VERBOSE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DVERBOSE=${VERBOSE}")
endif()

if(FIXED_SEED)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DFIXED_SEED")
endif()

if(NUM_OF_TESTS)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DNUM_OF_TESTS=${NUM_OF_TESTS}")
endif()

if(LEVEL)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DLEVEL=${LEVEL}")
endif()

# Standalone implementation features an implementation of AES that uses
# AES-NI and SSE3 x86 instructions (which means it is not fully portable).
# The fully portable implementation uses OpenSSL for AES and it can run
# on any CPU architecture as long as OpenSSL is available.
if(STANDALONE_IMPL)
  if((NOT X86_64) AND (NOT X86))
    message(FATAL_ERROR " Standalone implementation works only on x86 systems.")
  endif()
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -maes -mssse3")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSTANDALONE_IMPL=${STANDALONE_IMPL}")
else()
  set(LINK_OPENSSL 1)
endif()

if(USE_NIST_RAND)
  if(FIXED_SEED)
    message(FATAL "Can't set both FIXED_SEED and USE_NIST_RAND")
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_NIST_RAND")

  # This code depends on OpenSSL
  set(LINK_OPENSSL 1)

endif()

# List all files with avx2 and avx512 suffix
FILE(GLOB_RECURSE AVX2_SRCS ${PROJECT_SOURCE_DIR}/src/*_avx2.c)
FILE(GLOB_RECURSE AVX512_SRCS ${PROJECT_SOURCE_DIR}/src/*_avx512.c)

set(AVX512_FLAGS "-mavx512f;-mavx512bw;-mavx512dq")

# Set appropriate flags for avx files
set_source_files_properties(${AVX2_SRCS} PROPERTIES COMPILE_OPTIONS "-mavx2")
set_source_files_properties(${AVX512_SRCS} PROPERTIES COMPILE_OPTIONS "${AVX512_FLAGS}")

set_source_files_properties(${PROJECT_SOURCE_DIR}/src/gf2x/gf2x_mul_base_pclmul.c PROPERTIES COMPILE_OPTIONS "-mpclmul;")
set_source_files_properties(${PROJECT_SOURCE_DIR}/src/gf2x/gf2x_mul_base_vpclmul.c PROPERTIES COMPILE_OPTIONS "-mvpclmulqdq;${AVX512_FLAGS}")