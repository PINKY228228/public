#include <cstdint>
#include "Rte_mock.h"
#include "ControlLamp.h"
#include <iostream>

extern "C" {

//typedef uint8_t Std_ReturnType;
//#define RTE_E_OK 0
//Std_ReturnType Rte_Read_VehicleSpeed_Value(uint16_t* speed);

extern "C" void RteMock_SetVehicleSpeed(uint16_t v);

}

/* ---- 内部モックデータ ---- */
static uint16_t mock_vehicleSpeed = 0;
static bool lamp_value;

/* ---- RTE API モック ---- */
extern "C" Std_ReturnType Rte_Read_VehicleSpeed_Value(uint16_t* speed)
{
    //*speed = gu16_vehicleSpeed;
    *speed = mock_vehicleSpeed;
    return RTE_E_OK;
}

/* ---- モック制御API ---- */
extern "C" void Rte_Write_VehicleSpeed_Value(uint16_t v)
{
    gu16_vehicleSpeed = v;
}

extern "C" Std_ReturnType Rte_Write_VehicleLamp_Value(bool v)
{
    std::cout << "Rte_Write called: " << v << std::endl;
    lamp_value = v;
    return RTE_E_OK;
}

extern "C" bool RteMock_GetVehicleLamp()
{
    return lamp_value;
}

extern "C" void RteMock_SetVehicleSpeed(uint16_t v)
{
    mock_vehicleSpeed = v;
}

extern "C" void Rte_Write_Lamp_Value(uint8_t v)
{
    gu16_vehicleSpeed = v;
}