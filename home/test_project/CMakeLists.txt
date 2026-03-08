cmake_minimum_required(VERSION 3.16)

project(test_project C CXX)

# Coverage option
option(ENABLE_COVERAGE "Enable coverage reporting" ON)

# if(ENABLE_COVERAGE)
    message("Coverage enabled")
    add_compile_options(--coverage -O0 -g)
    add_link_options(--coverage)
# endif()

enable_testing()

# --------------------
# GoogleTest
# --------------------
add_subdirectory(third_party/googletest)

# --------------------
# ライブラリ
# --------------------
add_library(my_lib
    src/add.c
)

target_include_directories(my_lib PUBLIC src)

# --------------------
# unit test
# --------------------
add_executable(unitTests
    tests/unit/test_add.cpp
)

target_link_libraries(unitTests
    my_lib
    gtest
    gtest_main
)

add_test(NAME unitTests COMMAND unitTests)

# --------------------
# csv test
# --------------------
add_executable(csvTests
    tests/csv/test_add_csv.cpp
    tests/csv/test_normal_csv.cpp
    tests/csv/csv_loader.cpp
)

target_link_libraries(csvTests
    my_lib
    gtest
    gtest_main
)

add_test(NAME csvTests COMMAND csvTests)

# --------------------
# data copy
# --------------------
file(COPY ${CMAKE_SOURCE_DIR}/data
     DESTINATION ${CMAKE_BINARY_DIR})