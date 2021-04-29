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

# TODO: download SDE if not availabale
INTEL_SDE=/home/ubuntu/workspace/intel_sde/sde64

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

if [ "$test_num" -lt "1" ]; then
    test_format "-DSTANDALONE_IMPL=1"
fi

if [ "$test_num" -lt "2" ]; then
    test_clang_tidy ""
    test_clang_tidy "-STANDALONE_IMPL=1"
    test_clang_tidy "-DRDTSC=1"
    test_clang_tidy "-DVERBOSE=1"
fi

# Test KATs
if [ "$test_num" -lt "3" ]; then
  test_kats ${INTEL_SDE}
  test_sanitizers ${INTEL_SDE}
fi

cd -
