#include "ControlLamp.h"

void App_VehicleSpeedProvider(void)
{
    Rte_Write_VehicleSpeed_Value(gu16_vehicleSpeed);
}
 
void App_ControlLamp(void)
{
    Rte_Write_VehicleSpeed_Value(gu16_vehicleSpeed);

if(gu16_vehicleSpeed > 100)
{
    Rte_Write_VehicleLamp_Value(TRUE);
}
else
{
    Rte_Write_VehicleLamp_Value(FALSE);
}
    printf("app:speed=%d\n", gu16_vehicleSpeed);
}