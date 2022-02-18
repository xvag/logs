#include <stdio.h>

int arr[] = {-5,-4,-3,-2,-1,0,1,2,3,4,5,};
int *ptr;

int main(void) {
	int i;
	ptr = &arr[0]; // ptr = arr;
	
	for(i=0;i<11;i++)
		printf("arr[%d] = %d (%p)\n",i,*(ptr+i),ptr+i);

	return 0;
}
