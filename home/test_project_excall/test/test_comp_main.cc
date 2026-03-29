#include <gtest/gtest.h>

extern "C" {
#include "comp.h"
}

static int call_order[2];
static int idx;

extern "C" void stub_comp_A(void)
{
    call_order[idx++] = 1;
}

extern "C" void stub_comp_B(void)
{
    //call_order[idx++] = 2;
call_order[idx++] = 1;
}

TEST(CompMainTest, CallOrder_A_then_B)
{
    idx = 0;

    set_comp_A(stub_comp_A);
    set_comp_B(stub_comp_B);

    comp_cycle();

    ASSERT_EQ(idx, 2);
    EXPECT_EQ(call_order[0], 1);
    EXPECT_EQ(call_order[1], 2);
}
#if 0
#include <gtest/gtest.h>
#include <gmock/gmock.h>

extern "C" {
#include "comp.h"
}

#include "mock_comp.h"

using ::testing::InSequence;

TEST(CompMainTest, CallOrder_A_then_B)
{
   MockComp mock;
    //g_mock = &mock;
//ASSERT_NE(g_mock, nullptr);   // ★これ追加

    //set_comp_A(comp_A);
    //set_comp_B(comp_B);

    //InSequence seq;
    //EXPECT_CALL(mock, comp_A()).Times(1);
    //EXPECT_CALL(mock, comp_B()).Times(1);

    comp_cycle();
}

int main(int argc, char** argv)
{
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
#endif