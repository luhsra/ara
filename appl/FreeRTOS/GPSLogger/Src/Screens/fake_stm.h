#ifndef FAKE_STM_H
#define FAKE_STM_H

struct I2C_HandleTypeDef {};
struct DMA_HandleTypeDef {};

void HAL_I2C_Mem_Write(I2C_HandleTypeDef*, int, int, int, unsigned char*, int, int);

void HAL_I2C_Mem_Write_DMA(I2C_HandleTypeDef*, int, int, int, unsigned char*, int);

#endif
