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
    uint16_t gu16_1_in;
    uint16_t gu16_2_in;
    int expected;
};

std::vector<TestData> loadCSV(const std::string& filename);
