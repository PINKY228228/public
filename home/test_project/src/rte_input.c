#include "ControlLamp.h"

uint16_t gu16_vehicleSpeed;
uint16_t gu16_1;
uint16_t gu16_2;
uint8_t gu8_i1;
uint8_t gu8_i2;
uint8_t gu8_i3;
uint8_t gu8_i4;
uint8_t gu8_i5;
uint8_t gu8_o1;
uint8_t gu8_activeTest;

uint8_t u8_temp; 

void App_init(void)
{
    uint16_t speed;
    u8_temp = 0;
    gu8_activeTest = 0;

    Rte_Read_VehicleSpeed_Value(&gu16_vehicleSpeed);
    Rte_Read_1(&gu16_1);
    Rte_Read_2(&gu16_2);

    Rte_Read_DID2800(&u8_temp);
    gu8_activeTest = gu8_activeTest | u8_temp;
    
    Rte_Read_DID2801(&u8_temp);
    gu8_activeTest = gu8_activeTest | u8_temp;

    if (gu8_i1 | gu8_i2 | gu8_i3 | gu8_i4 | gu8_i5)
    {
        gu8_o1 = 1;
    }
    else
    {
        gu8_o1 = 0;
    }
/*
    if(speed > 100)
    {
        Rte_Write_Lamp_Value(TRUE);
    }
*/        
}
