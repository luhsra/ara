/**
 * Test case for constant propagation and dead code elemination
 */
int number() {
	int a = 30;
	int b = 9 - (a / 5);
	int c;

	c = b * 4;
	if (c > 10) {
		c = c - 10;
	}
	return c * (60 / a);
}

int main(int argc, char** argv) {
	int c = number();

	if (c) {
		return 10;
	}

	int fob = argc * 2 + argc * 2;
	return fob;
}
