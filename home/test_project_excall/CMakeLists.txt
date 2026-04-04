cmake_minimum_required(VERSION 3.10)
project(test C CXX)

set(CMAKE_CXX_STANDARD 17)

set(BUILD_SHARED_LIBS OFF)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

enable_testing()

# add_subdirectory(../googletest googletest_build)
add_subdirectory(${CMAKE_SOURCE_DIR}/../googletest
                 ${CMAKE_BINARY_DIR}/googletest-build
                 EXCLUDE_FROM_ALL)

add_executable(unitTests
    src/comp_main.c
    test/mock_comp.cc
    #test/test_comp_main.cc
    test/test_comp_main_gmock.cc
)

target_include_directories(unitTests
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

#依存ライブラリ
target_link_libraries(unitTests PRIVATE
    mock
    GTest::GTest
    GTest::Main
    GTest::gmock
)
#target_link_libraries(unitTests
#    gtest
#    gtest_main
#    gmock        # ←追加
    #gmock_main   # ←追加（任意）
    #Threads::Threads
#)

# ★これ追加
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-subsystem,console")

# unitTestsがテスト名
# add_test は「exe単位」
# TEST() は「exe内のテスト単位」
#add_test(NAME unitTests COMMAND unitTests)
add_test(NAME unitTests
    # フィルタ
    #COMMAND unitTests --gtest_filter=CompMainTest.*
     COMMAND unitTests --gtest_filter=Runnable.*
)