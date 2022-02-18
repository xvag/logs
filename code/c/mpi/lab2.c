/*
 This program uses MPI to distribute the following calculations 
 to the predefined number of processes/ors:
	1. Addition of two 2D tables: C(NxN) + D(NxN)
	2. Multiplication of a 2D table by a column vector: C(NxN) * B(Nx1)
	3. Multiplication of a row vector by a column vector: A(1xN) * B(Nx1)
	4. Multiplication of a column vector by a row vector: B(Nx1) * A(1xN)

 Assumes that n%p = 0
 Where n is the num of elements in the tables and p is the num of proc/s
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "mpi.h"

int main(int argc, char** argv) {

	int my_rank;
	int p, n;
	int nperp;
	int q;
	int opt;
	int i, j;

/* 	Initial tables. 
	A2 and B2 are table declarations for the A and B 
	tables (as *A and *B), but for use with the 
	MPI_Bcast which doesn't handle pointer variables.
	(or I haven't found the way to do it - yet)
*/
	int A2[100];
	int B2[100];
	int *A, *B;
	int **C, *C_2D;
	int **D, *D_2D;

/*
	Tables to store the results.
*/
	int **CD, *CD_2D;
	int *CB;
	int AB;
	int **BA, *BA_2D;

/*
	Local tables for each proc.
*/
	int *A_loc, *B_loc;
	int AB_loc;
	int *C_loc;
	int *D_loc;
	int *CD_loc;
	int *CB_loc;
	int *BA_loc;
	

	char proc_name[MPI_MAX_PROCESSOR_NAME];
	int namelen;

	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&my_rank);
	MPI_Comm_size(MPI_COMM_WORLD,&p);
	MPI_Get_processor_name(proc_name, &namelen);

/*
	Proc 0 initializes the tables.
*/
	if(my_rank==0) {
		printf("Give N:\n");
		scanf("%d",&n);
		printf("1. C(NxN) + D(NxN)\n");
		printf("2. C(NxN) * B(Nx1)\n");
		printf("3. A(1xN) * B(Nx1)\n");
		printf("4. B(Nx1) * A(1xN)\n");
		printf("Select Calculation (1-4):\n");
		scanf("%d", &opt);
		
		if (opt==1) {
			// allocate mem for 2 2D tables (n*n).
			C_2D = (int *)malloc(n*n*sizeof(int));
			D_2D = (int *)malloc(n*n*sizeof(int));
			C = malloc(n*sizeof(int *));
			D = malloc(n*sizeof(int *));
			
			// point the pointers to create the 2D C,D tables.
			for (i=0; i<n; i++) {
				C[i] = C_2D + (i*n);
				D[i] = D_2D + (i*n);
			}

			// allocate mem for a 2D table (n*n) to store the result.
			CD_2D = (int *)malloc(n*n*sizeof(int));
			CD = malloc(n*sizeof(int *));
			
			// point the pointers to create the 2D CD table.
			for (i=0; i<n; i++)
				CD[i] = CD_2D + (i*n);
			
			// fill the two 2D tables (C,D) with values.
			for (i=0; i<n; i++){
				for(j=0; j<n; j++){
					C[i][j] = i*10+j+1;
					D[i][j] = i*10+j+1;
				}
			}
			// print table C
			printf("\n\nTable C(NxN):");
			for (i=0; i<n; i++){
				printf("\n");
				for (j=0; j<n; j++)
					printf("%3d ", C[i][j]);
			}

			// print table D
			printf("\n\nTable D(NxN):");
			for (i=0; i<n; i++){
				printf("\n");
				for (j=0; j<n; j++)
					printf("%3d ", D[i][j]);
			}
			printf("\n");
		}else if (opt==2) {
			// allocate mem for two tables. One 2D and one 1D.
			C_2D = (int *)malloc(n*n*sizeof(int));
			C = malloc(n*sizeof(int *));
			//B = (int *)malloc(n*sizeof(int));
			
			// point the pointers for the 2D table.
			for (i=0; i<n; i++)
				C[i] = C_2D + (i*n);

			// allocate mem for a table (n) to store the result.
			CB = (int *)malloc(n*sizeof(int));

			// fill the tables with values.
			for (i=0; i<n; i++) {
				B2[i] = i+1;
				for (j=0; j<n; j++)
					C[i][j] = i*10+j+1;
			}
			
			// print the tables.
			printf("\n\nTable B(Nx1):\n");
			for (i=0; i<n; i++)
				printf("%3d\n", B2[i]);

			printf("\n\nTable C(NxN):");
			for (i=0; i<n; i++) {
				printf("\n");
				for (j=0; j<n; j++)
					printf("%3d ",C[i][j]);
			}
			printf("\n");
		}else if (opt==3) {
			// allocate mem for the tables.
			A = (int *)malloc(n*sizeof(int));
			B = (int *)malloc(n*sizeof(int));

			// fill the tables with values.
			for (i=0; i<n; i++) {
				A[i] = i+1;
				B[i] = i+1;
			}
		
			// print the tables.
			printf("\n\nTable A(1xN):\n");
			for (i=0; i<n; i++)
				printf("%d ", A[i]);
			printf("\n");

			printf("\n\nTable B(Nx1):\n");
			for (i=0; i<n; i++)
				printf("%d\n", B[i]);
			printf("\n");
		}else if (opt==4) {
			// allocate mem for table A and BA for the result.
			A = (int *)malloc(n*sizeof(int));
			
			BA_2D = (int *)malloc(n*n*sizeof(int));
			BA = malloc(n*sizeof(int *));

			// point the pointers for the 2D table BA.
			for (i=0; i<n; i++)
				BA[i] = BA_2D + (i*n);

			// fill tables A and B with values.			
			for (i=0; i<n; i++) {
				A[i] = i+1;
				B2[i] = i+1;
			}

			// print the tables.
			printf("\n\nTable A(1xN)\n");
			for (i=0; i<n; i++)
				printf("%d ", A[i]);
			printf("\n");

			printf("\n\nTable B(Nx1)\n");
			for (i=0; i<n; i++)
				printf("%d\n", B2[i]);

			printf("\n");
		}else{
			printf("Wrong option\n");
		}
	}

/*
	All available proc/s participate in the calculations.
*/

	MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Bcast(&opt, 1, MPI_INT, 0, MPI_COMM_WORLD);
	nperp = n/p;

	if (opt==1) {
		q = nperp*n;

		// Each proc allocates mem for the local tables C and D.
		C_loc = (int *)malloc(q*sizeof(int));
		D_loc = (int *)malloc(q*sizeof(int));

		// Proc 0 scatters the tables to every other proc, including itself.
		MPI_Scatter(C_2D, q, MPI_INT, C_loc, q, MPI_INT, 0, MPI_COMM_WORLD);
		MPI_Scatter(D_2D, q, MPI_INT, D_loc, q, MPI_INT, 0, MPI_COMM_WORLD);

		// Calculations executed by every proc for the C+D.
		CD_loc = (int *)malloc(q*sizeof(int));
		for (i=0; i<q; i++)
			CD_loc[i] = C_loc[i] + D_loc[i];
	
		// Each proc prints its result.
		sleep(my_rank);
		printf("\nResult of PROC[%d]:\n", my_rank);
		for (i=0; i<q; i++){
			printf(" %d", CD_loc[i]);
		}
		printf("\n");

		// Proc 0 gathers the results from each proc.
		MPI_Gather(CD_loc, q, MPI_INT, CD_2D, q, MPI_INT, 0, MPI_COMM_WORLD);

	} else if (opt==2) {
		q=nperp*n;

		// Each proc allocates mem for local table C.
		C_loc = (int *)malloc(q*sizeof(int));

		// Proc 0 scatters table C and broadcasts table B.
		MPI_Scatter(C_2D, q, MPI_INT, C_loc, q, MPI_INT, 0, MPI_COMM_WORLD);
		MPI_Bcast(B2, n, MPI_INT, 0, MPI_COMM_WORLD);
		
		// Calculations executed by every proc for the C*B.
		CB_loc = (int *)malloc(nperp*sizeof(int));
		for (i=0; i<nperp; i++) {
			CB_loc[i] = 0;
			for (j=0; j<n; j++){
				CB_loc[i] += C_loc[i*n+j] * B2[j];
			}
		}

		// Each proc prints its results.
		sleep(my_rank);
		printf("\n\nResult of PROC[%d]:\n", my_rank);
		for (i=0; i<nperp; i++) {
			printf(" %d", CB_loc[i]);
		}
		printf("\n");

		// Proc 0 gathers the results.
		MPI_Gather(CB_loc, nperp, MPI_INT, CB, nperp, MPI_INT, 0, MPI_COMM_WORLD);
		
	} else if (opt==3) {
		// Each proc allocates mem for local tables A and B.
		A_loc=(int *)malloc(nperp*sizeof(int));
		B_loc=(int *)malloc(nperp*sizeof(int));
		
		// Proc 0 scatters tables A and B.
		MPI_Scatter(A, nperp, MPI_INT, A_loc, nperp, MPI_INT, 0, MPI_COMM_WORLD);
		MPI_Scatter(B, nperp, MPI_INT, B_loc, nperp, MPI_INT, 0, MPI_COMM_WORLD);

		// Calculations executed by every proc for the A*B.
		AB_loc=0;
		for(i=0; i<nperp; i++)
			AB_loc += A_loc[i] * B_loc[i];

		// Each proc prints its results.
		sleep(my_rank);
		printf("Result of PROC[%d]: %d\n",my_rank, AB_loc);

		// Proc 0 gathers and adds up the results from all procs.
		MPI_Reduce(&AB_loc, &AB, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

	} else if (opt==4) {
		q = nperp * n;

		// Each proc allocates mem for local table A.
		A_loc=(int *)malloc(nperp*sizeof(int));

		// Proc 0 scatters table A and broadcasts table B.
		MPI_Scatter(A, nperp, MPI_INT, A_loc, nperp, MPI_INT, 0, MPI_COMM_WORLD);
		MPI_Bcast(B2, n, MPI_INT, 0, MPI_COMM_WORLD);

		// Calculations executed by every proc for the B*A.
		BA_loc = (int *)malloc(q*sizeof(int));
		for (i=0; i<nperp; i++) 
			for (j=0; j<n; j++)
				BA_loc[i*n+j] = A_loc[i] * B2[j];
	
		// Each proc prints its results.
		sleep(my_rank);
		printf("\nResult of PROC[%d]:\n", my_rank);
		for (i=0; i<nperp*n; i++) {
			printf(" %d", BA_loc[i]);
		}
		printf("\n");

		// Proc 0 gathers the results from all procs.
		MPI_Gather(BA_loc, q, MPI_INT, BA_2D, q, MPI_INT, 0, MPI_COMM_WORLD);

	}

/*
	Proc 0 prints the final results
*/
	if (my_rank==0) {

		if (opt==1) {
			printf("\nFinal result: C+D =");
			for (i=0; i<n; i++) {
				printf("\n");
				for (j=0; j<n; j++)
					printf("%3d ", CD[i][j]);
			}

		} else if (opt==2) {
			printf("\nFinal result: C*B =\n");
			for (i=0; i<n; i++)
				printf("%d\n", CB[i]);

		} else if (opt==3) {
			printf("\nFinal result: A*B = %d\n", AB);

		} else if (opt==4) {
			printf("\nFinal result: B*A =");
			for (i=0; i<n; i++) {
				printf("\n");
				for (j=0; j<n; j++)
					printf("%3d ", BA[i][j]);
			}
		}

		printf("\n");
	}

	MPI_Finalize();
	
	return 0;
}
