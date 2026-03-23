#include <stdint.h>

extern uint16_t gu16_vehicleSpeed;
extern uint16_t gu16_1;
extern uint16_t gu16_2;
extern uint8_t gu8_i1;
extern uint8_t gu8_i2;
extern uint8_t gu8_i3;
extern uint8_t gu8_i4;
extern uint8_t gu8_i5;
extern uint8_t gu8_o1;
extern uint8_t gu8_activeTest;

void App_init(void);
void App_ControlLamp(void);

void App_ControlLamp(void);
void App_VehicleSpeedProvider(uint16_t speed);
#define TRUE 0
#define FALSE ~TRUE