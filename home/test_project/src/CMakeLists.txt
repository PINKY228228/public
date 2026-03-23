# ソースファイル名べた書きでなく、srcフォルダ内の*.cをテスト対象にする
file(GLOB SRC_FILES *.c)

add_library(my_lib
    ${SRC_FILES}
)

# add_library(my_lib
#     add.c
#     ControlLamp.c
# )

target_include_directories(my_lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Branches:を表示するため
if(ENABLE_COVERAGE)
    target_compile_options(my_lib PRIVATE -O0 -g -fprofile-arcs -ftest-coverage)
endif()

    #target_compile_options(my_lib PRIVATE -O0 -g --coverage)
    #target_link_options(my_lib PRIVATE --coverage)
