#ifndef RTE_MOCK_H
#define RTE_MOCK_H

#include <stdint.h>

typedef uint8_t Std_ReturnType;

#define RTE_E_OK 0

/* mock変数 */
extern uint16_t mock_speed;
extern uint16_t mock_torque;

/* RTE関数 */
Std_ReturnType Rte_Read_Speed(uint16_t* speed);
Std_ReturnType Rte_Write_Torque(uint16_t torque);

#endif