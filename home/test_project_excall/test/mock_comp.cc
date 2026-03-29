#include "mock_comp.h"
#include <assert.h>

MockComp* g_mock = nullptr;

extern "C" void comp_A(void)
{
    assert(g_mock != nullptr);
    g_mock->comp_A();
}

extern "C" void comp_B(void)
{
    assert(g_mock != nullptr);
    g_mock->comp_B();
}