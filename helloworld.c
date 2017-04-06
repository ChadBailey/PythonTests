#include <stdio.h>
/* This is a comment - compile with gcc helloworld.c and run with ./a.out */
#include <float.h>

int main()
{
	int a, b, c;
	float f;
	const int LENGTH = 10;
	const int WIDTH = 5;

    printf("Hello,\t\t world!\n");
    printf("Storage size for int : %d \n", sizeof(int));
    printf("Storage size for float : %d \n", sizeof(float));
	printf("Minimum float positive value: %E\n", FLT_MIN );
	printf("Maximum float positive value: %E\n", FLT_MAX );
	printf("Precision value: %d\n", FLT_DIG );
	a = 10;
	b = 20;

	c = a + b;
	printf("value of c=a+b: %d+%d=%d \n", a,b,c);

	int area;
	area = LENGTH * WIDTH;
	printf("value of area : %d\n\n", area);
    
    f = 70.0/3.0;
	printf("value of f : %f \n", f);
    
    return 0;
}
