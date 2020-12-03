#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

struct Foo {
	virtual ~Foo() {}
	virtual void do_stuff() = 0;
};

struct Bar : public Foo {
	int d;

	Bar(int d) : d(d) {}

	void do_stuff() override {
		vTaskDelay(d);
	}
};

struct Baz : public Foo {
	int d;

	Baz(int d) : d(d) {}

	void do_stuff() override {
		vTaskDelay(d*d);
	}
};

struct OneRoot {
	virtual ~OneRoot() {}
	virtual void quack() = 0;
};

struct TwoRoot {
	virtual ~TwoRoot() {}
	virtual void run() = 0;
};

struct Multi : public OneRoot, public TwoRoot {
	int d;

	Multi(int d) : d(d) {}

	void quack() override {
		vTaskDelay(d*d);
	}

	void run() override {
		vTaskDelay(d+d);
	}
};

int num();

Foo* get_foo();
OneRoot* get_or() {
	if (num()) {
		return new Multi(num());
	}
	return nullptr;
}

TwoRoot* get_tr() {
	if (num()) {
		return new Multi(num());
	}
	return nullptr;
}

int ptr_func1(int a, float b, int c) { return a + c; }

int ptr_func2(int a, float b, int c) { vTaskDelay(5); return a - c; }

typedef int (*PtrFunc)(int, float, int);
PtrFunc get_ptr_func();

PtrFunc complex_get_ptr_func(int a) {
	if (a < 12) {
		return ptr_func1;
	} else {
		return ptr_func2;
	}
}

int main(void) {
	// this is optimized out and therefore unambiguous
	auto ptr = ptr_func1;
	ptr(23, 4.5, 20);

	// this is impossible to optimize out
	auto ptr2 = get_ptr_func();
	ptr2(23, 4.5, 20);

	// this can be solved
	auto ptr3 = complex_get_ptr_func(23);
	ptr3(23, 4.5, 20);

	// vTable entry resolvable
	Foo* f = new Bar(5);
	f->do_stuff();
	delete f;

	// vTable unresolvable
	Foo* f2 = get_foo();
	f2->do_stuff();

	// vTable unresolvable
	OneRoot* o = get_or();
	o->quack();
	TwoRoot* t = get_tr();
	t->run();

	return 0;
}

int num() {
  return (int)main * 37 & (1<<23);
}
