
#include <thread>
#include <unistd.h>
#include <iostream>
 
void foo() 
{
  sleep(1);
}

int main() 
{
  std::thread foo_thread (foo);
  foo_thread.join();
  std::cout << "foo_thread returned!" << std::endl;
  return 0;
}