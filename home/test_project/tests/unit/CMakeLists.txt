# “純粋な単体テスト専用”
add_executable(unitTests
    test_add.cpp
    ../csv/csv_loader.cpp
    test_comp_main.cpp
    ../developer/mock_comp.cc   #←これ追加
    ../../src/comp_main.c
    #FlashTest.cpp
#    ../developer/MockIO.cc      # ★ここに入れる
 ../developer/FakeMicroTime.cc
 ../developer/MockIO.cc
    LegacyFlashTest.cpp
    #$<TARGET_OBJECTS:dev_mocks>
)

# Rte_mock.cc → ライブラリ dev_mocks を作る
# 自前mainをccで作成しない
target_link_libraries(unitTests
    dev_mocks    
    my_lib
    gtest
    pthread
)

# unitTests に include path を追加
target_include_directories(unitTests
    PRIVATE
    ${PROJECT_SOURCE_DIR}/tests/csv
    ${PROJECT_SOURCE_DIR}/tests/developer
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/src/IO
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
    #COMMAND unitTests --gtest_filter=LegacyFlash.*
    #COMMAND unitTests --gtest_filter=CompMainTest.*
    #COMMAND unitTests --gtest_filter=FlashDriverTest.*
     COMMAND unitTests --gtest_filter=RTEWrite.*
    # COMMAND unitTests --gtest_filter=RTEread.*
    # COMMAND unitTests --gtest_filter=VehicleSpeedTest.*
    #COMMAND unitTests --gtest_filter=RTEread.abstruct
)