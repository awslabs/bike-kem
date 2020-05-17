#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

function test_kats {
  if [ $# -eq 0 ]; then
    echo "No flags supplied.";
    exit
  fi

  flags=$1

  mkdir build
  mkdir artifacts
  cd build

  for build_type in "Release" "Debug"; do
    for level in "1" "3"; do
      cmake $flags -DCMAKE_BUILD_TYPE=$build_type -DLEVEL=$level -DUSE_NIST_RAND=1 ../../;
      make -j20
      ./bike-test
      cp PQCkemKAT_BIKE* ../artifacts/
      rm -rf *
    done
    
    diff ../artifacts/PQCkemKAT_BIKE_5223.rsp ../../tests/kats/BIKE_L1.kat > /dev/null
    diff ../artifacts/PQCkemKAT_BIKE_10105.rsp ../../tests/kats/BIKE_L3.kat > /dev/null
    
    rm -rf ../artifacts/*
  done

  # Cleaning  
  cd -
  rm -rf build
  rm -rf artifacts
}
