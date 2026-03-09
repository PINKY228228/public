add_executable(csvTests
    test_add_csv.cpp
    test_normal_csv.cpp
    csv_loader.cpp
)

target_link_libraries(csvTests
    my_lib
    gtest
    gtest_main
    dev_mocks
)

target_compile_definitions(csvTests PRIVATE
    TEST_DATA_DIR="${CMAKE_SOURCE_DIR}/data"
)

add_test(NAME csvTests COMMAND csvTests)