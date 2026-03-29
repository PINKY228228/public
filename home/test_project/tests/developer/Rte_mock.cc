#include <cstdint>
#include "Rte_mock.h"
#include "ControlLamp.h"
#include <iostream>

/*「mock変数を関数ごとに持つ設計」をやめる*/
/* 名前→値のマップで管理する */
#include <map>
#include <string>
static std::map<std::string, uint16_t> mock_map;

extern "C" {

//typedef uint8_t Std_ReturnType;
//#define RTE_E_OK 0
//Std_ReturnType Rte_Read_VehicleSpeed_Value(uint16_t* speed);

extern "C" void RteMock_SetVehicleSpeed(uint16_t v);

}

/* ---- 内部モックデータ ---- */
static uint16_t mock_vehicleSpeed = 0;
static uint16_t mock_R1 = 0;

static bool lamp_value;
struct MockDID
{
    uint8_t did2800;
    uint8_t did2801;
};

static MockDID mock;

/* ---- RTE API モック ---- */
extern "C" Std_ReturnType Rte_Read_VehicleSpeed_Value(uint16_t* speed)
{
    //*speed = gu16_vehicleSpeed;
    *speed = mock_vehicleSpeed;
    return RTE_E_OK;
}

/*「mock変数を関数ごとに持つ設計」をやめる*/
/* ①モック */
extern "C" Std_ReturnType Rte_Read_1(uint16_t* v)
{
    *v = mock_map["Rte_Read_1"];
    return RTE_E_OK;
}

extern "C" Std_ReturnType Rte_Read_2(uint16_t* v)
{
    *v = mock_map["Rte_Read_2"];
    return RTE_E_OK;
}
/*
extern "C" Std_ReturnType Rte_Read_1(uint16_t* v)
{
    *v = mock_R1;
    return RTE_E_OK;
}

extern "C" Std_ReturnType Rte_Read_2(uint16_t* v)
{
    *v = mock_R1;
    return RTE_E_OK;
}
*/
extern "C" Std_ReturnType Rte_Read_DID2800(uint8_t* v)
{
    *v = mock.did2800;
    return RTE_E_OK;    
}

extern "C" Std_ReturnType Rte_Read_DID2801(uint8_t* v)
{
    *v = mock.did2801;
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

/*「mock変数を関数ごとに持つ設計」をやめる*/
/* ②/*「mock変数を関数ごとに持つ設計」をやめる*/
/* ①Setter（1個で全部対応） */
extern "C" void RteMock_Set(const char* name, uint16_t val)
{
    mock_map[name] = val;
}

extern "C" void RteMock_SetU16Read(uint16_t v0)
{
    mock_R1 = v0;
}  


void RteMock_SetDID(uint8_t v0, uint8_t v1)
{
    mock.did2800 = v0;
    mock.did2801 = v1;
}    

extern "C" void Rte_Write_Lamp_Value(uint8_t v)
{
    gu16_vehicleSpeed = v;
}