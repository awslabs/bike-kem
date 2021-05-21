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

# Download Intel SDE if it's not available on the system
intel_sde=sde64
if ! command -v ${intel_sde} &> /dev/null
then
    echo "sde64 could not be found, downloading the program..."
    intel_sde_ver=sde-external-8.63.0-2021-01-18-lin
    rm -rf ${intel_sde_ver} ${intel_sde_ver}.tar.bz2
    wget https://software.intel.com/content/dam/develop/external/us/en/documents/downloads/${intel_sde_ver}.tar.bz2
    tar -xvjf sde-external-8.63.0-2021-01-18-lin.tar.bz2
    rm ${intel_sde_ver}.tar.bz2
    if ! command -v ${intel_sde_ver}/sde64 &> /dev/null
    then
      echo "Downloading Intel SDE was NOT successful, please download the program manually."
      exit
    fi
    intel_sde=`realpath ${intel_sde_ver}/sde64`
fi

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
  test_kats ${intel_sde}
  test_kats ${intel_sde} 1       # Test the binded pk and m version
  test_kats ${intel_sde} 2       # Test the sha3 and shake version
  test_kats ${intel_sde} 3       # Test the binded pk and m and sha3 version
  test_sanitizers ${intel_sde}
  test_sanitizers ${intel_sde} 1 # Test the binded pk and m version
  test_sanitizers ${intel_sde} 2 # Test the sha3 and shake version
  test_sanitizers ${intel_sde} 3 # Test the binded pk and m and sha3 version
fi

cd ${basedir}
