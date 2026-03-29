#add_library(dev_mocks OBJECT
#    Rte_mock.cc
#    mock_comp.cc
#    MockIO.cc
#    FakeMicroTime.cc
#)

add_library(dev_mocks
    Rte_mock.cc
    mock_comp.cc
    MockIO.cc
    FakeMicroTime.cc
)

# Flash driverでgooglemockを使うため、追加
target_link_libraries(dev_mocks
    my_lib     # ← srcのコード
    gmock
    gtest
    gtest_main
    pthread
)

target_include_directories(dev_mocks
    PRIVATE
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/src/IO
    ${CMAKE_CURRENT_SOURCE_DIR}
)