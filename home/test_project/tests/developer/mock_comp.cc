// mock_comp.cc

#include "mock_comp.h"

MockComp* g_mock = nullptr;

// C関数をフック
extern "C" void comp_A(void)
{
        printf("HERE\n");
    fflush(stdout);
    while(1);

    assert(g_mock != nullptr);
    g_mock->callA();
}

extern "C" void comp_B(void)
{
    assert(g_mock != nullptr);
    g_mock->callB();
}