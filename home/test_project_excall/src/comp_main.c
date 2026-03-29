#include "comp.h"

static comp_func_t comp_A_impl = 0;
static comp_func_t comp_B_impl = 0;

void set_comp_A(comp_func_t f) { comp_A_impl = f; }
void set_comp_B(comp_func_t f) { comp_B_impl = f; }

void comp_cycle(void)
{
    if (comp_A_impl) comp_A_impl();
    if (comp_B_impl) comp_B_impl();
}