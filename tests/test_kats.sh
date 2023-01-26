#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

function test_kats {
  # By default we test the Round-4 BIKE
  flag=""
  kat_l1=BIKE_L1.kat
  kat_l3=BIKE_L3.kat
  kat_l5=BIKE_L5.kat

  # The second function argument specifies a variant of BIKE to be tested.
  # So far there is only one variant: binded public key and message.
  if [ $# -eq 1 ]; then
    if [ $1 -eq 1 ]; then
      flag="-DUNIFORM_SAMPLING=1 -DUSE_AES_AND_SHA2=1"
      kat_l1=round3/BIKE_L1.kat
      kat_l3=round3/BIKE_L3.kat
      kat_l5=round3/BIKE_L5.kat
    elif [ $1 -eq 2 ]; then
      flag="-DUNIFORM_SAMPLING=1 -DUSE_AES_AND_SHA2=1 -DBIND_PK_AND_M=1"
      kat_l1=round3/BIKE_L1_binding.kat
      kat_l3=round3/BIKE_L3_binding.kat
      kat_l5=round3/BIKE_L5_binding.kat
    elif [ $1 -eq 3 ]; then
      flag="-DUNIFORM_SAMPLING=1"
      kat_l1=round3/BIKE_L1_sha3.kat
      kat_l3=round3/BIKE_L3_sha3.kat
      kat_l5=round3/BIKE_L5_sha3.kat
    elif [ $1 -eq 4 ]; then
      flag="-DUNIFORM_SAMPLING=1 -DBIND_PK_AND_M=1"
      kat_l1=round3/BIKE_L1_binding_sha3.kat
      kat_l3=round3/BIKE_L3_binding_sha3.kat
      kat_l5=round3/BIKE_L5_binding_sha3.kat
    fi
  fi

  mkdir build
  cd build

  for build_type in "Release" "Debug"; do
    for level in "1" "3" "5"; do
        for extra_flag in "" "-DSTANDALONE_IMPL=1"; do

          cmake -DCMAKE_BUILD_TYPE=$build_type -DLEVEL=$level -DUSE_NIST_RAND=1 ${flag} ${extra_flag} ../../;
          make -j
          ./bike-test
          if [ "$level" = "1" ]; then
            diff PQCkemKAT_BIKE_5223.rsp ../../tests/kats/${kat_l1} > /dev/null
          elif [ "$level" = "3" ]; then
            diff PQCkemKAT_BIKE_10105.rsp ../../tests/kats/${kat_l3} > /dev/null
          else
            diff PQCkemKAT_BIKE_16494.rsp ../../tests/kats/${kat_l5} > /dev/null
          fi
          rm -rf *
        done
      done
    done

  # Cleaning
  cd -
  rm -rf build
}
