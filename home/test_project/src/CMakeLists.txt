# ソースファイル名べた書きでなく、srcフォルダ内の*.cをテスト対象にする
file(GLOB_RECURSE SRC_FILES
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.c"
)

# テスト時は「本物のMicroTime.cを除外」する
list(FILTER SRC_FILES EXCLUDE REGEX ".*MicroTime\\.c$")
list(FILTER SRC_FILES EXCLUDE REGEX ".*IO\\.c$")

add_library(my_lib ${SRC_FILES})

target_include_directories(my_lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Branches:を表示するため
if(ENABLE_COVERAGE)
    target_compile_options(my_lib PRIVATE -O0 -g -fprofile-arcs -ftest-coverage)
endif()
