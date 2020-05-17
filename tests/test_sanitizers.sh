#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

num_of_tests=10

function test_sanitizers {
  if [ $# -eq 0 ]; then
    echo "No flags supplied.";
    exit
  fi

  flags=$1

  # Currently this test runs only with clang-9
  if [ -z "${CC}" ]; then
    return
  fi
  if [ ! "${CC}" = "clang-9" ]; then
    return
  fi  

  for sanitizer in "-DASAN=1" "-DMSAN=1" "-DTSAN=1" "-DUBSAN=1" ; do
    for level in "1" "3"; do
      CC=clang-9 cmake $flags -DCMAKE_BUILD_TYPE=Release -DNUM_OF_TESTS=$num_of_tests -DLEVEL=$level $sanitizer ..;
      make -j20
      ./bike-test
      rm -rf *
    done
  done
}

