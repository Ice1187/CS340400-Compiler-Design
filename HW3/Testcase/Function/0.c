void codegen();
int modulo(int a, int b);
int gcd(int a, int b);

void codegen()
{
  int a = gcd(12, 18); // a = 6
  int b = gcd(8, 9); // b = 1
  digitalWrite(26 + modulo(6, 4), 1);
  delay(b * 1000);
  digitalWrite(26 + modulo(6, 4), 0);
  delay(b * 1000);
}

int modulo(int a, int b)
{
  return a - a / b * b;
}

int gcd(int a, int b)
{
  if (b != 0)
  {
    return gcd(b, modulo(a, b));
  }
  else
  {
    return a;
  }
}

