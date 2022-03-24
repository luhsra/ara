
typedef union { int a[8]; void* b[8]; } test_struct;

test_struct global_var = {{0}};

int main() {}