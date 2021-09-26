cmake_minimum_required(VERSION 3.0.0)
project(bike C)

set(INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set(SRC_DIR ${PROJECT_SOURCE_DIR}/src)
set(TESTS_DIR ${PROJECT_SOURCE_DIR}/tests)

include_directories(${INCLUDE_DIR})
include_directories(${INCLUDE_DIR}/internal)
include_directories(${SRC_DIR}/third_party_src)

include(cmake/arch.cmake)
include(cmake/compilation-flags.cmake)
include(cmake/clang-format.cmake)

add_library(${PROJECT_NAME} "")
add_executable(bike-test "")

add_subdirectory(${SRC_DIR})
add_subdirectory(${TESTS_DIR})

target_link_libraries(bike-test ${PROJECT_NAME})

if(LINK_OPENSSL)
  message(STATUS "Linking OpenSSL")
  find_package(OpenSSL REQUIRED)
  set(OPENSSL_USE_STATIC_LIBS TRUE)
  target_link_libraries(bike-test OpenSSL::Crypto)
endif()
