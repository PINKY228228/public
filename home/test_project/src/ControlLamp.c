#include "ControlLamp.h"

#include <stdint.h>
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