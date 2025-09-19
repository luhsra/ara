
/*
 * Minimal Bare Metal OS App
 */

// examplary OS-specific function that is abstracted away
extern "C" void printk(char *);

// hypercall that is found by analaysis
extern "C" void BareMetal_Dummy(int);

// Ara internal IIT
extern "C" void ara_timing_info(int a, int b);

void IR() {
	ara_timing_info(1, 2);
    printk("important IR");
    printk("bye12");
}

void do_1() {
    printk("Hello");
	ara_timing_info(5, 6);
    BareMetal_Dummy(5);
	ara_timing_info(7, 8);
    printk("bye12");
}

int main(){
    int x = 7;
	ara_timing_info(1, 2);
    BareMetal_Dummy(x);
	ara_timing_info(3, 4);
    do_1();
	ara_timing_info(9, 10);
}
