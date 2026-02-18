
/*
 * Minimal Bare Metal OS App
 */

#include "bare_metal/os.h"

int main(){
	ara_timing_info(1, 2);
    BareMetal_Idle();
}
