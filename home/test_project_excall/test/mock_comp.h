#pragma once
#include <gmock/gmock.h>

class MockComp {
public:
    MOCK_METHOD(void, comp_A, ());
    MOCK_METHOD(void, comp_B, ());
};

extern MockComp* g_mock;

extern "C" void comp_A(void);
extern "C" void comp_B(void);