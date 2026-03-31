//#ifndef RTE_MOCK_H
//#define RTE_MOCK_H
#pragma once
#include <any>
#include <map>
#include <string>
extern std::map<std::string, std::any> write_map;

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
Std_ReturnType Rte_Read_1(uint16_t* v);
Std_ReturnType Rte_Read_2(uint16_t* v);
Std_ReturnType Rte_Read_DID2800(uint8_t* v);
Std_ReturnType Rte_Read_DID2801(uint8_t* v);

Std_ReturnType Rte_Write_VehicleSpeed_Value(uint16_t v);
void RteMock_SetVehicleSpeed(uint16_t v);
void RteMock_Set(const char* name, uint16_t val);
void RteMock_SetU16Read(uint16_t v0);
void RteMock_SetU8Read(uint8_t v0);
void RteMock_SetDID(uint8_t v0, uint8_t v1);

#ifdef __cplusplus
}
#endif

//#endif