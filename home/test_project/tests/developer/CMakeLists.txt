add_library(dev_mocks
    Rte_mock.c
)

target_include_directories(dev_mocks PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)