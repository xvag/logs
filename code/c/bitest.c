#include <stdio.h>

void main()
{
	int b;
	int x=255;

	for (b=0; x!=0; x>>=1)
		if (x&01)
			b++;
	printf("%d\n",b);
}

