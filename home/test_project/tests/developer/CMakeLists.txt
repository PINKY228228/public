add_library(dev_mocks
    Rte_mock.cc
)

target_include_directories(dev_mocks PUBLIC
    PRIVATE
    ${PROJECT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}
)