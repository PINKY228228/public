# ① 共通部
add_library(test_common STATIC
    #test_add.cpp
    test_main.cpp
    ../csv/csv_loader.cpp
    ../developer/FakeMicroTime.cc
    ../developer/MockIO.cc
)

target_include_directories(test_common
    PUBLIC
    ${PROJECT_SOURCE_DIR}/tests/csv
    ${PROJECT_SOURCE_DIR}/tests/developer
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/src/IO
)

target_link_libraries(test_common
    PUBLIC gtest   # ★これ追加
    PUBLIC gmock   # ★これ追加
)

target_compile_definitions(test_common
    PUBLIC CSV_PATH="${PROJECT_SOURCE_DIR}/tests/csv/"
)

# ② comp_main用
#rte_output.c は入ってない
#App_ControlLamp = モックだけ存在
#⇒衝突なし
#func_aをcomp_main.cとmock_comp.ccに存在させると
#⇒衝突
#リンカは「同名関数1つだけ」しか許さない
#⇒func_aは別ファイルとし、通常ビルドには入れる／単体テスト（comp_main）には入れない
add_executable(unitTests_comp_main
    test_main.cpp
    ../../src/comp_main.c
    ../developer/mock_comp.cc   # ← App_ControlLampモック
)

target_link_libraries(unitTests_comp_main
    test_common
    my_lib
    # gtest # test_common で gtest PUBLICしてるので重複
    gmock      # ★これ追加
    gtest_main   
    pthread
)

add_test(NAME unitTests_comp_main
    COMMAND unitTests_comp_main --gtest_filter=main.*
)

# ③ rte_output用
add_executable(unitTests_rte_output
    test_add.cpp
    ../../src/rte_output.c
)

target_link_libraries(unitTests_rte_output
    test_common
    dev_mocks     # ← Rte_Writeモック
    my_lib
    gtest
    pthread
)

add_test(NAME unitTests_rte_output
    COMMAND unitTests_rte_output --gtest_filter=RTEWrite.*
)

# その他
add_executable(unitTests_flash
    LegacyFlashTest.cpp
)

target_link_libraries(unitTests_flash
    test_common
    my_lib
    gtest
    gtest_main   # ★これ追加
    pthread
)

#add_test(NAME unitTests_flash
    #COMMAND unitTests_flash --gtest_filter=FlashDriverTest.*
#)