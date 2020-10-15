#include <stdint.h>

extern uint32_t _ssparsespec;
extern uint32_t _esparsespec;
extern uint32_t _sisparsespec;
// extern uint32_t _sisparse;



// extern "C" void
// sparse_init () {


// 	//RLE
// 	uint32_t* start = &_sisparsespec;

// 	while(start < &_esparsespec){
// 		if((*(start) == 0 && *(start+1) == 2 && *(start+2) == 0)){
// 			//if start flag found
// 			start += 3;
// 			uint32_t* addr = (uint32_t*) *start;
// 			uint32_t value = *(start+1);
// 			uint32_t byte = *(start+2);
// 			uint32_t length = *(start+3);
// 			start += 1;

// 			while(1){
// 				if(value == 0 && byte == 1 && length == 0){
// 					//if start variable flag found
// 					start += 3;
// 					if((*(start) == 0 && *(start+1) == 3 && *(start+2) == 0)) break; //if end flag found
// 					addr = (uint32_t*) *start;
// 					value = *(start+1);
// 					byte = *(start+2);
// 					length = *(start+3);
// 					start += 1;
// 				}else if(value == 0 && byte == 2 && length == 0){
// 					break;
// 				}

// 				//write value length times address
// 				// if(byte == 4){
// 					uint32_t* i = addr + length;
// 					while(addr < i){
// 						*addr = value;
// 						addr++;
// 					}
// 				// }else if(byte == 2){
// 				// 	uint16_t* calcAddr = (uint16_t*) addr;
// 				// 	uint16_t* i = calcAddr + length;
// 				// 	while(calcAddr < i){
// 				// 		*calcAddr++ = value;
// 				// 	}
// 				// 	addr = (uint32_t*) calcAddr;
// 				// }else if(byte == 1){
// 				// 	unsigned char* calcAddr = (unsigned char*) addr;
// 				// 	unsigned char* i = calcAddr + length;
// 				// 	while(calcAddr < i){
// 				// 		*calcAddr++ = value;
// 				// 	}
// 				// 	addr = (uint32_t*) calcAddr;
// 				// }

// 				//next entry
// 				start += 3;
// 				value = *(start);
// 				byte = *(start+1);
// 				length = *(start+2);
// 			}
// 			start++;
// 		}else{
// 			start++;
// 		}
// 	}
// }


extern uint32_t _ssparsespec2;
extern uint32_t _esparsespec2;

extern "C" void init_sparserle2() {
  uint32_t *current = &_ssparsespec2;

  uint32_t *addr;
  while (current < &_esparsespec2) {
	uint32_t repetitions = *current++;
	if (repetitions == 0) {
	  addr = (uint32_t*) *current++;
	  continue;
	}
	if (repetitions & (1<<31)) { //verbatim
	  repetitions = repetitions & ~(1<<31);
	  while (repetitions != 0) {
		*addr++ = *current++;
		repetitions--;
	  }
	} else { //repeating
	  uint32_t val = *current++;
	  while (repetitions-- != 0) {
		*addr++ = val;
	  }
	}
  }
}
