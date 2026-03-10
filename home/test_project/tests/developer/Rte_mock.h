#ifndef RTE_MOCK_H
#define RTE_MOCK_H

#include <stdint.h>


/* mock変数 */
extern uint16_t mock_speed;
extern uint16_t mock_torque;

#ifdef __cplusplus
extern "C" {
#endif

typedef uint8_t Std_ReturnType;

#define RTE_E_OK 0

/* RTE関数 */
Std_ReturnType Rte_Write_VehicleLamp_Value(bool v);
bool RteMock_GetVehicleLamp(void);

Std_ReturnType Rte_Read_Speed(uint16_t* speed);
Std_ReturnType Rte_Write_Torque(uint16_t torque);
Std_ReturnType Rte_Read_VehicleSpeed_Value(uint16_t* speed);
void RteMock_SetVehicleSpeed(uint16_t v);

#ifdef __cplusplus
}
#endif

#endif