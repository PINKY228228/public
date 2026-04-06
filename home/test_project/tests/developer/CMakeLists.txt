set(MOCK_DIR ${CMAKE_CURRENT_SOURCE_DIR}/mock)

add_library(dev_mocks
    ${CMAKE_CURRENT_SOURCE_DIR}/mock/Rte_mock.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/mock/mock_comp.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/MockIO.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/mock/FakeMicroTime.cc
)

# Flash driverでgooglemockを使うため、追加
target_link_libraries(dev_mocks
    my_lib
    GTest::gmock
    GTest::gtest
    GTest::gtest_main
    pthread
)

#target_link_libraries(dev_mocks
#    my_lib     # ← srcのコード
#    gmock
#    gtest
#    gtest_main
#    pthread
#)

target_include_directories(dev_mocks
    PRIVATE
    ${PROJECT_SOURCE_DIR}/../src
    ${PROJECT_SOURCE_DIR}/../src/IO        
#   ${PROJECT_SOURCE_DIR}/src
#    ${PROJECT_SOURCE_DIR}/src/IO
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${MOCK_DIR}
)