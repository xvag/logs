#include <stdio.h>

int a[10];
float f[10];
char b[10]="abcdefghij";
double df[10];
int i;

void main(){

	for(i=0; i<10; i++)
	{
		float j;
		a[i]=i+10;
		j=i+0.0;
		f[i]=j+10.0;
		df[i]=j+10.0;
	}

	for(i=0; i<10; i++)
		printf("%d\t%c\t%3.3f\t%5.5f\n",a[i],b[i],f[i],df[i]);

	printf("\n");
	for (i=0; i<10; i++)
	{
		printf("a_add:     %d\n",a+i);
		printf("a_add_hex: %04x\n\n",a+i);

		printf("b_add:     %d\n",b+i);
		printf("b_add_hex: %04x\n\n",b+i);

		printf("f_add:     %d\n",f+i);
		printf("f_add_hex: %04x\n\n",f+i);

		printf("df_add:     %d\n",df+i);
		printf("df_add_hex: %04x\n\n",df+i);
	
	}
}
