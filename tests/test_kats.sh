#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

function test_kats {
  if [ $# -eq 0 ]; then
    echo "No Intel SDE path supplied.";
    exit
  fi

  intel_sde=$1

  # By default we test the Round-3 BIKE
  flag=""
  kat_l1=BIKE_L1.kat
  kat_l3=BIKE_L3.kat

  # The second function argument specifies a variant of BIKE to be tested.
  # So far there is only one variant: binded public key and message.
  if [ $# -eq 2 ]; then
    if [ $2 -eq 1 ]; then
      flag="-DBIND_PK_AND_M=1"
      kat_l1=BIKE_L1_binding.kat
      kat_l3=BIKE_L3_binding.kat
    fi
  fi

  mkdir build
  cd build

  for build_type in "Release" "Debug"; do
    for level in "1" "3"; do
      for arch in "icl" "skl" "hsw" "snb" "nhm"; do
        for extra_flag in "" "-DSTANDALONE_IMPL=1"; do

          # Standalone implementation requires AES-NI instructions
          # which are not available on Nehalem CPU.
          if [ "$arch" = "nhm" ] && [ "$extra_flag" = "-DSTANDALONE_IMPL=1" ]; then
            continue
          fi

          cmake -DCMAKE_BUILD_TYPE=$build_type -DLEVEL=$level -DUSE_NIST_RAND=1 ${flag} ${extra_flag} ../../;
          make -j8
          $intel_sde -$arch -- ./bike-test
          if [ "$level" = "1" ]; then
            diff PQCkemKAT_BIKE_5223.rsp ../../tests/kats/${kat_l1} > /dev/null
          else
            diff PQCkemKAT_BIKE_10105.rsp ../../tests/kats/${kat_l3} > /dev/null
          fi
          rm -rf *
        done
      done
    done
  done

  # Cleaning
  cd -
  rm -rf build
}
