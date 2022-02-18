#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {

	int i, j, n;

	int *A, *B;
	int *C_2D;
	int *D_2D;
	int **C;
	int **D;
	
	int *CB;
	int AB;

	int *BA_2D;
	int **BA;

	printf("Give N: \n");
	scanf("%d",&n);
		
	C_2D = (int *)malloc(n*n*sizeof(int));
	D_2D = (int *)malloc(n*n*sizeof(int));
	A = (int *)malloc(n*sizeof(int));
	B = (int *)malloc(n*sizeof(int));

	C = malloc(n*sizeof(int *));
	D = malloc(n*sizeof(int *));

	for (i=0; i<n; i++){
		C[i] = C_2D + (i*n);
		D[i] = D_2D + (i*n);
	}
	
	for (i=0; i<n; i++) {
		A[i] = i+1;
		B[i] = i+1;
		for (j=0; j<n; j++) {
			C[i][j] = i*10+j+1;
			D[i][j] = i*10+j+1;
		}
	}
	
	printf("\n[A]\n");
	for (i=0; i<n; i++)
		printf("%d ", A[i]);

	printf("\n\n[B]\n");
	for (i=0; i<n; i++)
		printf("%d\n", B[i]);
	
	printf("\n\n[C]");
	for (i=0; i<n; i++){
		printf("\n");
		for (j=0; j<n; j++)
			printf("%3d ", C[i][j]);
	}
	
	printf("\n -%d- \n", C_2D[9]);
	
	printf("\n\n[D]");
	for (i=0; i<n; i++){
		printf("\n");
		for (j=0; j<n; j++)
			printf("%3d ", D[i][j]);
	}

	printf("\n\n[C]+[D]=");
	for (i=0; i<n; i++){
		printf("\n");
		for (j=0; j<n; j++)
			printf("%3d ", C[i][j] + D[i][j]);
	}
	
	CB = (int *)malloc(n*sizeof(int));
	printf("\n\n[C]*[B]=\n");
	for (i=0; i<n; i++){
		CB[i]=0;
		for (j=0; j<n; j++)
			CB[i]+=C[i][j]*B[j];
		printf("%3d\n", CB[i]);
	}

	AB = 0;
	printf("\n\n[A]*[B]=\n");
	for (i=0; i<n; i++)
		AB+=A[i]*B[i];
	printf("%d", AB);

	
	BA_2D = (int *)malloc(n*n*sizeof(int));
	BA = malloc(n*sizeof(int *));
	for (i=0; i<n; i++)
		BA[i] = BA_2D + (i*n);
	printf("\n\n[B]*[A]=\n");
	for (i=0; i<n; i++)
		for (j=0; j<n; j++)
			BA[i][j] = A[i]*B[j];

	for (i=0; i<n; i++){
		for (j=0; j<n; j++)
			printf("%3d ", BA[i][j]);
		printf("\n");
	}
	
	printf("\n");
 
	return 0;
}
