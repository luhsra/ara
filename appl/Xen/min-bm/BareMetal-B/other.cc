
/*
 * Minimal App
 */

extern "C" void printk(char *);

void do_1() {
    printk("blub");
}


int main(){
    do_1();
}
