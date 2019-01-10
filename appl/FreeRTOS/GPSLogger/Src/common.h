#ifndef common
#define common

void LL_GPIO_SetPinMode(uint32_t, uint32_t, uint32_t);
void LL_GPIO_SetPinOutputType(uint32_t, uint32_t, uint32_t);
void LL_GPIO_SetPinSpeed(uint32_t, uint32_t, uint32_t);
void LL_GPIO_ResetOutputPin(uint32_t, uint32_t);
void LL_GPIO_SetOutputPin(uint32_t, uint32_t);
void LL_GPIO_TogglePin(uint32_t, uint32_t);
void LL_GPIO_SetPinPull(uint32_t, uint32_t, uint32_t);
bool LL_GPIO_IsInputPinSet(uint32_t, uint32_t);

		// Prepare for initialization
void LL_USART_Disable(uint32_t);

		// Init
void LL_USART_SetBaudRate(uint32_t, uint32_t,uint32_t);
void LL_USART_SetDataWidth(uint32_t, uint32_t);
void LL_USART_SetStopBitsLength(uint32_t, uint32_t);
void LL_USART_SetParity(uint32_t, uint32_t);
void LL_USART_SetTransferDirection(uint32_t, uint32_t);
void LL_USART_SetHWFlowCtrl(uint32_t, uint32_t);

void LL_USART_EnableIT_RXNE(uint32_t);
void HAL_NVIC_EnableIRQ(uint32_t);
void HAL_NVIC_SetPriority(uint32_t, uint32_t,uint32_t);
void LL_USART_Enable(uint32_t);
uint32_t LL_USART_ReceiveData8(uint32_t);
uint32_t HAL_RCC_GetPCLK2Freq();
void HAL_Delay( uint32_t Delay);
uint32_t HAL_GetTick();

uint32_t LL_GPIO_SPEED_FREQ_HIGH = 1;
uint32_t LL_GPIO_SPEED_FREQ_MEDIUM = 1;
uint32_t LL_GPIO_SPEED_FREQ_LOW = 1;
uint32_t LL_GPIO_OUTPUT_PUSHPULL = 1;
uint32_t LL_GPIO_MODE_OUTPUT = 1;
uint32_t LL_GPIO_MODE_ALTERNATE = 1;
uint32_t LL_GPIO_PIN_0 = 13;
uint32_t LL_GPIO_PIN_1 = 13;
uint32_t LL_GPIO_PIN_2 = 12;
uint32_t LL_GPIO_PIN_3 = 13;
uint32_t LL_GPIO_PIN_4 = 12;
uint32_t LL_GPIO_PIN_5 = 13;
uint32_t LL_GPIO_PIN_6 = 12;
uint32_t LL_GPIO_PIN_7 = 13;
uint32_t LL_GPIO_PIN_8 = 12;
uint32_t LL_GPIO_PIN_9 = 13;
uint32_t LL_GPIO_PIN_10 = 12;
uint32_t LL_GPIO_PIN_11 = 12;
uint32_t LL_GPIO_PIN_12 = 13;
uint32_t LL_GPIO_PIN_13 = 12;
uint32_t LL_GPIO_PIN_14 = 12;
uint32_t LL_GPIO_PIN_15 = 13;
uint32_t LL_GPIO_PIN_16 = 12;
uint32_t LL_GPIO_PULL_UP = 13;
uint32_t LL_GPIO_MODE_INPUT = 13;
uint32_t GPIOC = 0;
uint32_t GPIOB = 0;
void * SPI2 ;
typedef struct 
 {
   void         *Instance;                                                        /*!< Register base address                  */
 
    int            Init;                                                             /*!< DMA communication parameters           */ 
    int             Lock;                                                             /*!< DMA locking object                     */  
 
    int  State;                                                            /*!< DMA transfer state                     */
 
   void                       *Parent;                                                          /*!< Parent object state                    */ 
 
   void                       (* XferCpltCallback)( struct __DMA_HandleTypeDef * hdma);         /*!< DMA transfer complete callback         */
 
   void                       (* XferHalfCpltCallback)( struct __DMA_HandleTypeDef * hdma);     /*!< DMA Half transfer complete callback    */
 
   void                       (* XferM1CpltCallback)( struct __DMA_HandleTypeDef * hdma);       /*!< DMA transfer complete Memory1 callback */
   
   void                       (* XferM1HalfCpltCallback)( struct __DMA_HandleTypeDef * hdma);   /*!< DMA transfer Half complete Memory1 callback */
   
   void                       (* XferErrorCallback)( struct __DMA_HandleTypeDef * hdma);        /*!< DMA transfer error callback            */
   
   void                       (* XferAbortCallback)( struct __DMA_HandleTypeDef * hdma);        /*!< DMA transfer Abort callback            */  
 
   uint32_t              ErrorCode;                                                        /*!< DMA Error code                          */
  
  uint32_t                   StreamBaseAddress;                                                /*!< DMA Stream Base Address                */
 
  uint32_t                   StreamIndex;                                                      /*!< DMA Stream Index                       */

}DMA_HandleTypeDef;


class FatFile{
    
    public:
    
        void write(char* buffer,  uint8_t len);
};

#endif //common
