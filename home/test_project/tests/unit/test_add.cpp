#include <gtest/gtest.h>

extern "C" {
#include "Rte_mock.h"
#include "../../src/add.h"
#include "ControlLamp.h"
}
/*
TEST
 ↓
RteMock_SetVehicleSpeed(120)
 ↓
App_ControlLamp()
 ↓
Rte_Read → 120
 ↓
if(speed > 100)
 ↓
Rte_Write(TRUE)
 ↓
mock保存
 ↓
EXPECT_TRUE
*/
TEST(LampTest, TurnOn)
{
    RteMock_SetVehicleSpeed(120);
    App_ControlLamp();
    EXPECT_FALSE(RteMock_GetVehicleLamp());
    /*EXPECT_EQ(RteMock_GetVehicleLamp(), true);*/
}

/*
TEST開始
 ↓
RteMock_SetVehicleSpeed(120)
 ↓
mock内部変数 vehicleSpeed = 120
 ↓
Rte_Read_VehicleSpeed_Value(&speed)
 ↓
speed = vehicleSpeed
 ↓
EXPECT_EQ(speed,120)
*/
TEST(VehicleSpeedTest, HighSpeed)
{
    RteMock_SetVehicleSpeed(120);
    uint16_t speed;
    Rte_Read_VehicleSpeed_Value(&speed);
    EXPECT_EQ(speed, 120);
}

// 基本テスト
TEST(AddTest, Basic)
{
    EXPECT_EQ(add(1,2),3);
}

// ゼロ
TEST(AddTest, Zero)
{
    EXPECT_EQ(add(0,0),0);
}

// 負数
TEST(AddTest, Negative)
{
    EXPECT_EQ(add(-5,3),-2);
}

// 大きい数
TEST(AddTest, Large)
{
    EXPECT_EQ(add(1000,2000),3000);
}