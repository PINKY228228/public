#include "ControlLamp.h"

void App_VehicleSpeedProvider(uint16_t speed)
{
    Rte_Write_VehicleSpeed_Value(speed);
}
 
void App_ControlLamp(void)
{
    unsigned int speed;

if(speed > 100)
{
    Rte_Write_VehicleLamp_Value(TRUE);
}
else
{
    Rte_Write_VehicleLamp_Value(FALSE);
}
    printf("speed=%d\n", speed);
}