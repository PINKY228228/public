// mock_comp.hpp

#ifndef MOCK_COMP_H
#define MOCK_COMP_H

#include "gmock/gmock.h"

class MockComp {
public:
    MOCK_METHOD(void, callA, ());
    MOCK_METHOD(void, callB, ());
};

// グローバルポインタ
extern MockComp* g_mock;

extern int gidx;
extern int gcall_order[2];

#endif