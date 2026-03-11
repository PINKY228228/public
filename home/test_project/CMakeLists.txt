cmake_minimum_required(VERSION 3.16)

project(test_project C CXX)

option(ENABLE_COVERAGE "Enable coverage" OFF)

if(ENABLE_COVERAGE)
    message(STATUS "Coverage enabled")

    add_compile_options(-O0 -g --coverage)
    add_link_options(--coverage)
endif()

enable_testing()

add_subdirectory(src)
add_subdirectory(tests)