add_library(my_lib
    add.c
    ControlLamp.c
)

target_include_directories(my_lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)