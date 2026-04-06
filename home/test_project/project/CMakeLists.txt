cmake_minimum_required(VERSION 3.16)

project(test_project C CXX)

option(ENABLE_COVERAGE "Enable coverage" OFF)

if(ENABLE_COVERAGE)
    message(STATUS "Coverage enabled")

    add_compile_options(-O0 -g -fprofile-arcs -ftest-coverage)
    add_link_options(--coverage)

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_C_FLAGS_DEBUG "-g -O0")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

enable_testing()

# googletest追加
# GTestを探す（なければ後でfallback）
find_package(GTest QUIET)

# 必要なら外部追加
if(NOT GTest_FOUND)
    message(STATUS "Using local googletest")

    get_filename_component(PARENT_DIR ${CMAKE_SOURCE_DIR} DIRECTORY)
add_subdirectory(
    ${CMAKE_SOURCE_DIR}/../../googletest
    ${CMAKE_BINARY_DIR}/googletest
)
else()
    message(STATUS "Using system GTest")
endif()

# 👇 ここだけ変える
add_subdirectory(${CMAKE_SOURCE_DIR}/../src ${CMAKE_BINARY_DIR}/src)
add_subdirectory(${CMAKE_SOURCE_DIR}/../tests ${CMAKE_BINARY_DIR}/tests)