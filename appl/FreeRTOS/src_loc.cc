#ifdef __cplusplus
extern "C" {
#if 0
}
#endif
#endif

int input();

int main() {
	int a = input();
	int b = input();
	a++;
	for (int i = 0; i < a; ++i) {
		b += a;
	}
	return a + b;
}

#ifdef __cplusplus
}
#endif
