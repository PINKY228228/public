cmake_minimum_required(VERSION 3.16)

project(test_project C CXX)

option(ENABLE_COVERAGE "Enable coverage" OFF)

if(ENABLE_COVERAGE)
    message(STATUS "Coverage enabled")

    add_compile_options(-O0 -g -fprofile-arcs -ftest-coverage)
    add_link_options(--coverage)

    # 👇 これが重要（gcov明示）
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
endif()

set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_C_FLAGS_DEBUG "-g -O0")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

enable_testing()

add_subdirectory(src)
add_subdirectory(tests)
# googletest追加
add_subdirectory(third_party/googletest)
