#ifndef _FREERTOSHELPERS_H_
#define _FREERTOSHELPERS_H_
#include "../Libs/FreeRTOS/Arduino_FreeRTOS.h"
class MutexLocker
{
public:
	MutexLocker(SemaphoreHandle_t mtx)
	{
        additional_attribute = 0;
        tmp = 210;
		mutex = mtx;
		xSemaphoreTake(mutex, portMAX_DELAY);
	}
	
	~MutexLocker()
	{
		xSemaphoreGive(mutex);
	}

private:
    double tmp;
    int additional_attribute;
	SemaphoreHandle_t mutex;	
};


#endif //_FREERTOSHELPERS_H_
