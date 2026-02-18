
/*
 * Minimal Bare Metal OS App
 */

#include "bare_metal/os.h"

int main(){
	ara_timing_info(3, 4);
    BareMetal_Dummy(5);

	ara_timing_info(7, 8);
    BareMetal_Idle();
}
