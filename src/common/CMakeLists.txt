# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0"

FILE(GLOB SRCS ${CMAKE_CURRENT_LIST_DIR}/*.c)
FILE(GLOB HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)

target_sources(${PROJECT_NAME} PRIVATE ${SRCS} ${HEADERS})
