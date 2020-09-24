#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void do_stuff(int a) {
	vTaskStepTick(a);
}

class Guard {
  private:
	int hidden;

  public:
	Guard(int hidden) : hidden(hidden) {}
	~Guard() { do_stuff(hidden); }
};

int main() {
	int a = 1234;
	int b = 333;
	int c = 6;
	int d = 4465;
	Guard guard(d);
	c++;
	int x = c;
	do_stuff(a);
	do_stuff(b);
	return x;
}
