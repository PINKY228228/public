#include <gtest/gtest.h>
#include "csv_loader.h"
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

TEST(RTEWriteTest, Rte_Write_VehicleSpeed_Value)
{
    uint16_t mockvalue=150;
    App_VehicleSpeedProvider(mockvalue);
    EXPECT_EQ(gu16_vehicleSpeed, mockvalue);
}

TEST(RTEWriteTest, TurnOn)
{
    uint16_t mockvalue=120;
    RteMock_SetVehicleSpeed(mockvalue);
    App_ControlLamp();
    EXPECT_FALSE(RteMock_GetVehicleLamp());
}

TEST(RTEread, LampTable)
{
/*
CSVテストは「入出力の組み合わせ確認」に向いている
典型例：テーブルテスト
CSV
 ↓
RTE入力に設定
 ↓
App実行
 ↓
RTE出力確認
*/
    auto rows = loadCSV("tests/csv/table_test.csv");

    /* 失敗行をわかるようにする */
for (const auto& r : rows)
{
    SCOPED_TRACE("speed=" + std::to_string(r.a));

    gu16_vehicleSpeed = r.a;
    App_ControlLamp();

    EXPECT_EQ(RteMock_GetVehicleLamp(), r.expected);
}    
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