#pragma once

#include <vector>
#include <string>

struct TestData
{
    int a;
    int b;
    int expected;
};

std::vector<TestData> loadCSV(const std::string& filename);