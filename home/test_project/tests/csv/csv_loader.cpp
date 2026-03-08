#include "csv_loader.h"

#include <fstream>
#include <sstream>
#include <iostream>

std::vector<TestData> loadCSV(const std::string& filename)
{
    std::vector<TestData> data;

    std::ifstream file(filename);

    if (!file.is_open())
    {
        std::cerr << "Cannot open CSV: " << filename << std::endl;
        return data;
    }

    std::string line;
    std::getline(file, line);

    while (std::getline(file, line))
    {
        std::stringstream ss(line);
        std::string cell;

        TestData t;

        std::getline(ss, cell, ',');
        t.a = std::stoi(cell);

        std::getline(ss, cell, ',');
        t.b = std::stoi(cell);

        std::getline(ss, cell, ',');
        t.expected = std::stoi(cell);

        data.push_back(t);
    }

    return data;
}