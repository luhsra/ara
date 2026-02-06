
/*
 * Minimal Bare Metal OS App
 */

// examplary OS-specific function that is abstracted away
extern "C" void printk(char *);

// hypercall that is found by analaysis
extern "C" void BareMetal_Dummy(int);

// syscall to terminate a control-flow
extern "C" void BareMetal_Idle();

// Ara internal IIT
extern "C" void ara_timing_info(int a, int b);

void do_1() {
    int x = 7;
    printk("Hello");
	ara_timing_info(2, 2);
    BareMetal_Dummy(5);
	ara_timing_info(3, 3);
    printk("bye12");
}

int main(){
	ara_timing_info(1, 1);
    do_1();
	ara_timing_info(4, 4);
    BareMetal_Idle();
}
