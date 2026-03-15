#pragma once

#include <vector>
#include <string>

/*
struct LampRow
{
    int speed;
    int expectedLamp;
};
std::vector<LampRow> loadCSV(const std::string& filename);
*/
struct TestData
{
    int a;
    int b;
    int expected;
};

std::vector<TestData> loadCSV(const std::string& filename);
