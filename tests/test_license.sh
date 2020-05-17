#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

var=`find . -type f | grep '\./src\|\./include\|\./cmake\|\./tests' | grep -v 'FromNIST' | grep -v '.kat' | xargs grep -L 'SPDX-License-Identifier: Apache-2.0'| sort`
if [ ! -z $var ]; then
  exit 1
fi
