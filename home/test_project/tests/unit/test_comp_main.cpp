// test_comp_main.cpp

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "mock_comp.h"

extern "C" {
#include "comp.h"
}

using ::testing::InSequence;
using ::testing::StrictMock;

TEST(CompMainTest, CallOrder_A_then_B)
{
    StrictMock<MockComp> mock;
    g_mock = &mock;
     printf("MOCK g_mock addr = %p\n", &g_mock);
    printf("MOCK g_mock val  = %p\n", g_mock);
 
    ASSERT_NE(g_mock, nullptr);
    {
        InSequence seq;

 //       EXPECT_CALL(mock, callA()).Times(1);
//        EXPECT_CALL(mock, comp_B()).Times(1);
    }

    comp_cycle();
}