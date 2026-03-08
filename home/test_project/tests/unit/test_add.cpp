#include <gtest/gtest.h>

extern "C" {
#include "../../src/add.h"
}

// 基本テスト
TEST(AddTest, Basic)
{
    EXPECT_EQ(add(1,2),3);
}

// ゼロ
TEST(AddTest, Zero)
{
    EXPECT_EQ(add(0,0),0);
}

// 負数
TEST(AddTest, Negative)
{
    EXPECT_EQ(add(-5,3),-2);
}

// 大きい数
TEST(AddTest, Large)
{
    EXPECT_EQ(add(1000,2000),3000);
}