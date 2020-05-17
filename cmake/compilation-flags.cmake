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

if(USE_OPENSSL)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_OPENSSL=${USE_OPENSSL}")
  set(LINK_OPENSSL 1)
else()
  # When not using OpenSSL we must enable SSSE3 and AES_NI support
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -maes -mssse3")
endif()

if(PORTABLE)

  if(AVX2)
    message(FATAL "AVX2 flag is not allowed when PORTABLE is selected")
  endif()
  
  if(AVX512)
    message(FATAL "AVX512 flag is not allowed when PORTABLE is selected")
  endif()
  
  if(PCLMUL)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mpclmul -DPCLMUL")
    set(SUFMUL _pclmul)
  else()
    set(SUFMUL _portable)
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DPORTABLE")
  set(SUF _portable)

else()

  if(VPCLMUL)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mvpclmulqdq -DVPCLMUL")
    set(SUFMUL _vpclmul)
    set(AVX512 1)
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mpclmul -DPCLMUL")
    set(SUFMUL _pclmul)
  endif()

  if(AVX512)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mavx512f -mavx512bw -mavx512dq -DAVX512")
    set(SUF _avx512)
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mavx2 -DAVX2")
    set(SUF _avx2)
  endif()
endif()


if(USE_NIST_RAND)
  if(FIXED_SEED)
    message(FATAL "Can't set both FIXED_SEED and USE_NIST_RAND")
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_NIST_RAND")

  # This code depends on OpenSSL
  set(LINK_OPENSSL 1)

endif()
