#     ../csv/csv_loader.cpp
add_executable(unitTests
    test_add.cpp
    ../csv/csv_loader.cpp
)

# Rte_mock.cc → ライブラリ dev_mocks を作る
target_link_libraries(unitTests
    my_lib
    gtest
    gtest_main
    dev_mocks
)

# unitTests に include path を追加
target_include_directories(unitTests
    PRIVATE
    ${PROJECT_SOURCE_DIR}/tests/csv
    ${PROJECT_SOURCE_DIR}/tests/developer
)

target_compile_definitions(unitTests
    PRIVATE CSV_PATH="${PROJECT_SOURCE_DIR}/tests/csv/"
)

# unitTestsがテスト名
add_test(NAME unitTests COMMAND unitTests)