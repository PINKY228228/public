// mock_comp.cc

#include "mock_comp.h"

int gidx;

int gcall_order[2];

MockComp* g_mock = nullptr;

// C関数をフック
extern "C" void func_a(void)
{
    gcall_order[gidx++] = 1;
}

extern "C" void App_ControlLamp(void)
{
    gcall_order[gidx++] = 2;
}

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