#include <gtest/gtest.h>

extern "C" {
#include "comp.h"
}

#include "mock_comp.h"

static int call_order[2];
static int idx;

extern "C" void stub_comp_A(void)
{
    call_order[idx++] = 1;
}

extern "C" void stub_comp_B(void)
{
    call_order[idx++] = 2;
    //call_order[idx++] = 1;
}

TEST(main, CallOrder_A_then_B)
{
    gidx = 0;

    comp_cycle2();

    ASSERT_EQ(gidx, 2);
    EXPECT_EQ(gcall_order[0], 1);
    EXPECT_EQ(gcall_order[1], 2);
}

TEST(main, functionPtr)
{
    idx = 0;

    set_comp_A(stub_comp_A);
    set_comp_B(stub_comp_B);

    comp_cycle();

    ASSERT_EQ(idx, 2);
    EXPECT_EQ(call_order[0], 1);
    EXPECT_EQ(call_order[1], 2);
}