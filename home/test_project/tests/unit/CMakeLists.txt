add_executable(unitTests
    test_add.cpp
)

target_link_libraries(unitTests
    my_lib
    gtest
    gtest_main
)

add_test(NAME unitTests COMMAND unitTests)