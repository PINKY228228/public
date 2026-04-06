cmake_minimum_required(VERSION 3.16)

project(test_project C CXX)

option(ENABLE_COVERAGE "Enable coverage" OFF)

if(ENABLE_COVERAGE)
    message(STATUS "Coverage enabled")

    add_compile_options(-O0 -g -fprofile-arcs -ftest-coverage)
    add_link_options(--coverage)

    # 👇 これが重要（gcov明示）
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_C_FLAGS_DEBUG "-g -O0")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

enable_testing()

add_subdirectory(src)
add_subdirectory(tests)

# googletest追加
find_package(GTest QUIET)
if(GTest_FOUND)
    message(STATUS "Using system GTest")
else()
    message(STATUS "Using local googletest")
# プロジェクト外に配置したgoogletestを参照するため、親ディレクトリ配下のgoogletestを指定する
# test_project3 の1つ上のディレクトリを取得するため、CMAKE_SOURCE_DIRの親ディレクトリを取得する
get_filename_component(PARENT_DIR ${CMAKE_SOURCE_DIR} DIRECTORY)
# また、ビルド生成物をソースと分離するため、バイナリディレクトリ側に出力先を指定する
add_subdirectory(
    ${PARENT_DIR}/googletest
    ${CMAKE_BINARY_DIR}/googletest
)    
endif()