#     ../csv/csv_loader.cpp
add_executable(unitTests
    test_add.cpp
    ../csv/csv_loader.cpp
    FlashTest.cpp
    ../developer/MockIO.cc      # ★ここに入れる
    ../developer/FakeMicroTime.cc    
)

# Rte_mock.cc → ライブラリ dev_mocks を作る
# 自前mainをccで作成しない
target_link_libraries(unitTests
    my_lib        # ★先（要求側）
    dev_mocks     # ★後（提供側）
    # gtest
    # gtest_main
    # gmockを使い、シーケンステストをしたいため
    gmock
    gmock_main    
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
# add_test は「exe単位」
# TEST() は「exe内のテスト単位」
#add_test(NAME unitTests COMMAND unitTests)
add_test(NAME unitTests
    # フィルタ
    COMMAND unitTests --gtest_filter=FlashDriverTest.*
    #COMMAND unitTests --gtest_filter=RTEread.*
    # COMMAND unitTests --gtest_filter=VehicleSpeedTest.*
)