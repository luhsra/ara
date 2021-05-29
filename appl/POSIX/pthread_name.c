#include <pthread.h>

int main()
{

  pthread_attr_t thread_attr;
  pthread_attr_init(&thread_attr);
  pthread_attr_setname_np(&thread_attr, "name of the thread");
  pthread_attr_destroy(&thread_attr);

  return 0;
}