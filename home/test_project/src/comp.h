// comp.h

#ifndef COMP_H
#define COMP_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*comp_func_t)(void);

void set_comp_A(comp_func_t f);
void set_comp_B(comp_func_t f);
void comp_cycle(void);

void comp_cycle2(void);
void func_a(void);
void func_b(void);

void comp_cycle(void);
void comp_A(void);
void comp_B(void);

#ifdef __cplusplus
}
#endif

#endif