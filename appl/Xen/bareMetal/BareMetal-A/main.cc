
/*
 * Minimal Zephyr App
 */

extern "C" void printk(char *);

void do_1() {
    printk("Hello");
    printk("bye12");
}

int main(){
    do_1();
}
