cmake_minimum_required(VERSION 3.16)

project(test_project C CXX)

enable_testing()

add_subdirectory(src)
add_subdirectory(tests)