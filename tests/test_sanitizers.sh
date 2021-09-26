#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

num_of_tests=10

function test_sanitizers {
  if [ $# -eq 0 ]; then
    echo "No Intel SDE path supplied.";
    exit
  fi

  intel_sde=$1

  flag=""
  # The second function argument specifies a variant of BIKE to be tested.
  # So far there is only one variant: binded public key and message.
  if [ $# -eq 2 ]; then
    if [ $2 -eq 1 ]; then
      flag="-DBIND_PK_AND_M=1"
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
      for arch in "icl" "skl" "hsw" "snb" "nhm"; do
        for extra_flag in "" "-DSTANDALONE_IMPL=1"; do

          # Standalone implementation requires AES-NI instructions
          # which are not available on Nehalem CPU.
          if [ "${arch}" = "nhm" ] && [ "${extra_flag}" = "-DSTANDALONE_IMPL=1" ]; then
            continue
          fi

          CC=clang-9 cmake -DCMAKE_BUILD_TYPE=Release -DNUM_OF_TESTS=${num_of_tests} -DLEVEL=${level} ${flag} ${extra_flag} ${sanitizer} ..;
          make -j8
          $intel_sde -${arch} -- ./bike-test
          rm -rf *
        done
      done
    done
  done
}

