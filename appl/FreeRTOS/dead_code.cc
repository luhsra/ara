int main(int argc, char ** argv) {
	int foo = 3;
	int bar = 3 + 5;
	int fob = argc * 2 + argc * 2;
	bar += foo;
	if (foo)
		return fob;
	else
		return bar;
	return fob;
}
