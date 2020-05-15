int main(void) {
  int a = 30;
  int b = 9 - (a / 5);
  int c;

  c = b * 4;
  if (c > 10) {
     c = c - 10;
  }
  return c * (60 / a);
}
