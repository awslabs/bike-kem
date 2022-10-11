#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

# Abort the script if any command failed to return 0
set -e

# Print the instructions
set -x

if [ $# -eq 0 ]; then
    echo "No arguments supplied - please supply a test level.";
    exit
fi

test_num=$1

# NOTE: Intel SDE can't be directly downloaded anymore so we are
#       disabling testing with the SDE for now.
# Download Intel SDE if it's not available on the system
# intel_sde=sde64
# if ! command -v ${intel_sde} &> /dev/null
# then
#     echo "sde64 could not be found, downloading the program..."
#     intel_sde_ver=sde-external-9.7.0-2022-05-09-lin
#     rm -rf ${intel_sde_ver} ${intel_sde_ver}.tar.xz
#     wget https://software.intel.com/content/dam/develop/external/us/en/documents/downloads/${intel_sde_ver}.tar.xz
#     tar -xvjf sde-external-8.63.0-2021-01-18-lin.tar.xz
#     rm ${intel_sde_ver}.tar.bz2
#     if ! command -v ${intel_sde_ver}/sde64 &> /dev/null
#     then
#       echo "Downloading Intel SDE was NOT successful, please download the program manually."
#       exit
#     fi
#     intel_sde=`realpath ${intel_sde_ver}/sde64`
# fi

# Avoid removing the "build" directory if the script does not run from the
# package root directory
basedir=`pwd`
if [[ ! -f "$basedir/tests/run_tests.sh" ]]; then
  >&2 echo "Script does not run from the root directory"
  exit 0
fi

source $(dirname $0)/test_license.sh
source $(dirname $0)/test_kats.sh
source $(dirname $0)/test_sanitizers.sh
source $(dirname $0)/test_format.sh
source $(dirname $0)/test_clang_tidy.sh

# Create a clean build directory
rm -rf build/
mkdir build;
cd build

if [ "${test_num}" -lt "1" ]; then
    test_format
    test_format "-DSTANDALONE_IMPL=1 -DBIND_PK_AND_M=1"
fi

# NOTE: clang-tidy is currently disabled because it doesn't know
#       how to handle the __cpuid_count function in cpu_features.c
#if [ "$test_num" -lt "2" ]; then
#    test_clang_tidy ""
#    test_clang_tidy "-STANDALONE_IMPL=1"
#    test_clang_tidy "-DRDTSC=1"
#    test_clang_tidy "-DVERBOSE=1"
#fi

# Test KATs
if [ "${test_num}" -lt "3" ]; then
  test_kats
  test_kats 1       # Test the round 3 version
  test_kats 2       # Test the round 3 + binded pk and m version
  test_kats 3       # Test the round 3 + sha3 and shake version
  test_kats 4       # Test the round 3 + binded pk and m and sha3 version
  test_sanitizers
  test_sanitizers 1 # Test the round 3 version
  test_sanitizers 2 # Test the round3 + binded pk and m version
  test_sanitizers 3 # Test the round3 + sha3 and shake version
  test_sanitizers 4 # Test the round3 + binded pk and m and sha3 version
fi

cd ${basedir}
