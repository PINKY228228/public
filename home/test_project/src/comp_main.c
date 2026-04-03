// comp_main.c

#include "stdio.h"
#include "comp.h"
#include "ControlLamp.h"

static comp_func_t comp_A_impl = 0;
static comp_func_t comp_B_impl = 0;

void set_comp_A(comp_func_t f) { comp_A_impl = f; }
void set_comp_B(comp_func_t f) { comp_B_impl = f; }

void comp_cycle(void)
{
    if (comp_A_impl) comp_A_impl();
    if (comp_B_impl) comp_B_impl();
}

void comp_cycle2(void)
{
    func_a();
    App_ControlLamp();
}

void func_b(void)
{

}

#if 0
void comp_cycle(void)
{
        printf("ENTER\n");
    fflush(stdout);

    comp_A();
    comp_B();
}
#endif