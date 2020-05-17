#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

function test_clang_tidy {
  # Test clang-tidy
  CC=clang-9 cmake $flag -DCMAKE_C_CLANG_TIDY="clang-tidy-9;--fix-errors;--format-style=file" ..
  make -j20
  rm -rf *
}

