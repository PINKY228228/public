#include <gtest/gtest.h>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <iostream>
#include "csv_loader.h"

extern "C" {
#include "../../src/add.h"
}

class AddCSVTest : public ::testing::TestWithParam<TestData> {};

TEST_P(AddCSVTest, Add)
{
    TestData t = GetParam();
    EXPECT_EQ(add(t.a, t.b), t.expected);
}

INSTANTIATE_TEST_SUITE_P(
    AddCSVTests,
    AddCSVTest,
    ::testing::ValuesIn(loadCSV(std::string(TEST_DATA_DIR) + "/add.csv"))
);