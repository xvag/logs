#include <stdio.h>

int j, k;
int *ptr;

int main(void) {
	j=1;
	k=2;
	ptr = &k;
	printf("\n");
	printf("j has value %d, stored at %p\n", j, (void *)&j);
	printf("k has value %d, stored at %p\n", k, (void *)&k);
	printf("ptr has value %p, stored at %p\n", ptr, (void *)&ptr);
	
	//ptr-=0xff;
	printf("Value of int pointed to by ptr is %d\n", *ptr);
	
	return 0;
}
