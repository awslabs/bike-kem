# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Some of the definitions in .clang-format require clang-format-9 and above.
find_program(CLANG_FORMAT
             NAMES 
                   clang-format-11
                   clang-format-10
                   clang-format-9
                   clang-format)

IF(CLANG_FORMAT)
  # Get the major version of clang-format 
  # CLANG_FORMAT_VERSION should be in the format "clang-format version [Major].[Minor].[Patch] <additional string>"
  exec_program(${CLANG_FORMAT} ${CMAKE_CURRENT_SOURCE_DIR} ARGS --version OUTPUT_VARIABLE CLANG_FORMAT_VERSION)
  STRING(REGEX REPLACE ".* ([0-9]+)\\.[0-9]+\\.[0-9]+.*" "\\1" CLANG_FORMAT_MAJOR_VERSION ${CLANG_FORMAT_VERSION})
  
  message(STATUS "Found version ${CLANG_FORMAT_MAJOR_VERSION} of clang-format.")
  if(${CLANG_FORMAT_MAJOR_VERSION} LESS "9")
    message(STATUS "To run the format target clang-format version >= 9 is required.")
  else()
    set(CLANG_FORMAT_FILE_TYPES ${CLANG_FORMAT_FILE_TYPES} )
    file(GLOB_RECURSE CF_FILES1 ${SRC_DIR}/*.c ${SRC_DIR}/*.h)
    file(GLOB_RECURSE CF_FILES2 ${INCLUDE_DIR}/*.h)
    set(FILES_TO_FORMAT "${CF_FILES1}" "${CF_FILES2}")

    ADD_CUSTOM_TARGET(
      format
      COMMAND ${CLANG_FORMAT} -i -style=file ${FILES_TO_FORMAT}
      COMMENT "Clang-formatting all (*.c/*.h) source files"
    )
  endif()
else()
  message(STATUS "Did not find clang-format.")
endif()
