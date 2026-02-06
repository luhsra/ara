
/*
 * Minimal Bare Metal OS App
 */

// syscall to terminate a control-flow
extern "C" void BareMetal_Idle();

// Ara internal IIT
extern "C" void ara_timing_info(int a, int b);


int main(){
	ara_timing_info(1, 2);
    BareMetal_Idle();
}
