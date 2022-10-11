#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

num_of_tests=10

function test_sanitizers {
  flag=""
  # The second function argument specifies a variant of BIKE to be tested.
  if [ $# -eq 1 ]; then
    if [ $1 -eq 1 ]; then
      flag="-DUNIFORM_SAMPLING=1 -DUSE_AES_AND_SHA2=1"
    elif [ $1 -eq 2 ]; then
      flag="-DUNIFORM_SAMPLING=1 -DUSE_AES_AND_SHA2=1 -DBIND_PK_AND_M=1"
    elif [ $1 -eq 3 ]; then
      flag="-DUNIFORM_SAMPLING=1"
    elif [ $1 -eq 4 ]; then
      flag="-DUNIFORM_SAMPLING=1 -DBIND_PK_AND_M=1"
    fi
  fi

  # Currently this test runs only with clang-9
  if ! command -v clang-9 &> /dev/null
  then
    >&2 echo "clang-9 could not be found"
    return
  fi

  for sanitizer in "-DASAN=1" "-DMSAN=1" "-DTSAN=1" "-DUBSAN=1" ; do
    for level in "1" "3"; do
        for extra_flag in "" "-DSTANDALONE_IMPL=1"; do

          CC=clang-9 cmake -DCMAKE_BUILD_TYPE=Release -DNUM_OF_TESTS=${num_of_tests} -DLEVEL=${level} ${flag} ${extra_flag} ${sanitizer} ..;
          make -j
          ./bike-test
          rm -rf *
        done
      done
    done
}

