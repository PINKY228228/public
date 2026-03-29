cmake_minimum_required(VERSION 3.10)
project(test C CXX)

set(CMAKE_CXX_STANDARD 17)

set(BUILD_SHARED_LIBS OFF)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_subdirectory(../googletest googletest_build)

add_executable(unitTests
    src/comp_main.c
    test/test_comp_main.cc
)

target_include_directories(unitTests
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(unitTests
    gtest
    gtest_main
    Threads::Threads
)

# ★これ追加
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-subsystem,console")