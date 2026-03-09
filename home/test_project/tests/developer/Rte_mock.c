#include "Rte_mock.h"

/* テスト用データ */
uint16_t mock_speed = 0;
uint16_t mock_torque = 0;

/* RTE read mock */
Std_ReturnType Rte_Read_Speed(uint16_t* speed)
{
    *speed = mock_speed;
    return RTE_E_OK;
}

/* RTE write mock */
Std_ReturnType Rte_Write_Torque(uint16_t torque)
{
    mock_torque = torque;
    return RTE_E_OK;
}