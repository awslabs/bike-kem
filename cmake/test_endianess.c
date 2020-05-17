// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>
#include <stdio.h>

int main(void)
{
  uint16_t uint_with_2_bytes = 0x0001;
  if (sizeof(uint_with_2_bytes) != 2) {
      printf("Undefined behaviour.\n");
      return 1;
  }      
      
  uint8_t *byte_array = (uint8_t*)&uint_with_2_bytes;
  if (byte_array[0] != 1) {
      printf("The code does not support big endian systems.\n");
      return 1;
  }
  
  printf("A little endian system.\n");

  return 0;
}
