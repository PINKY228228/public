add_executable(unitTests
    test_add.cpp
)

# Rte_mock.cc → ライブラリ dev_mocks を作る
target_link_libraries(unitTests
    my_lib
    gtest
    gtest_main
    dev_mocks
)

# unitTestsがテスト名
add_test(NAME unitTests COMMAND unitTests)