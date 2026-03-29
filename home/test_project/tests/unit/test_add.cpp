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
#if 1
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
#endif
TEST(RTEread, Rte_Read_VehicleSpeed_Value)
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
    auto rows = loadCSV(std::string(CSV_PATH) + "table_test.csv");
 
for (const auto& r : rows)
{
    /* 失敗行をわかるようにする */
    SCOPED_TRACE("speed=" + std::to_string(r.a));
    /* モック入力を設定 */
    RteMock_SetVehicleSpeed(r.a);
    App_init();
/* EXPECT_EQ(期待値, 実際の値); */
    EXPECT_EQ(r.a, gu16_vehicleSpeed);
}    
}

TEST(RTEread, Rte_Read_1)
{
    auto rows = loadCSV(std::string(CSV_PATH) + "gu16_1.csv");
 
    for (const auto& r : rows)
    {
    /* 失敗行をわかるようにする */
        //SCOPED_TRACE("speed=" + std::to_string(r.a));
    /* モック入力を設定 */
        /*「mock変数を関数ごとに持つ設計」をやめる*/
        RteMock_Set("Rte_Read_1", r.gu16_1_in);
        RteMock_Set("Rte_Read_2", r.gu16_2_in);
        //RteMock_SetU16Read(r.gu16_1_in);
        //RteMock_SetU16Read(r.gu16_2_in);

        App_init();
/* EXPECT_EQ(期待値, 実際の値); */
        EXPECT_EQ(r.gu16_1_in, gu16_1);
        EXPECT_EQ(r.gu16_2_in, gu16_2);
    }    
}

TEST(RTEread, abstruct)
{
    auto rows = loadCSV2(std::string(CSV_PATH) + "abstruct.csv");
 
    for (const auto& r : rows)
    {
    /* 失敗行をわかるようにする */
        //SCOPED_TRACE("speed=" + std::to_string(r.a));
    /* モック入力を設定 */
        //RteMock_Set("Rte_Read_1", r.gu16_1_in);
        gu8_i1 = r.gu8_i1_in;
        gu8_i2 = r.gu8_i2_in;
        gu8_i3 = r.gu8_i3_in;
        gu8_i4 = r.gu8_i4_in;
        gu8_i5 = r.gu8_i5_in;
        App_init();
/* EXPECT_EQ(期待値, 実際の値); */
        EXPECT_EQ(r.gu8_o1_ideal, gu8_o1);
    }    
}

TEST(RTEread, gu8_activeTest)
{
    auto rows = loadCSV(std::string(CSV_PATH) + "gu8_activeTest.csv");
 
for (const auto& r : rows)
{
    /* モック入力を設定 */
    RteMock_SetDID(r.a, r.b);
    App_init();
/* EXPECT_EQ(期待値, 実際の値); */
    EXPECT_EQ(r.expected, gu8_activeTest);
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
#if 1
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
#endif