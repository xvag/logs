/*******************************************************************
 *
 * A similar example that uses MPI_Scatterv and MPI_Gatherv
 *
 * The program should be run with exactly 8 processes.
 * Process 0 initializes a matrix (x) of 8 by 8 integers and distributes
 * the lower triangular part of the matrix to the processes using
 * MPI_Scatterv. The processes receive different number of elements:
 * process 0 gets one element, process 1 gets 2 elements and process i
 * gets i+1 elements. The elements of all processes are then gathered 
 * (using MPI_Gatherv) again in another 8 by 8 matrix (res) of process 0
 * (which is initialized with zeros) in triangular shape.
 *
 * ********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"
#define MAXPROC 8    /* Max number of procsses */
#define LENGTH 8    /*  Size of matrix is LENGTH * LENGTH */

main(int argc, char* argv[]) {
  int i, j, np, me;
  const int root = 0;         /* Root process in scatter */
  
  int x[LENGTH][LENGTH];        /* Send buffer */
  int y[LENGTH];                /* Receive buffer */
  int res[LENGTH][LENGTH];      /* Final receive buffer */

  int *sendcount, *recvcount;  /* Arrays for sendcounts and recvcounts */
  int *displs1, *displs2;  /* Arrays for displacements */

  MPI_Init(&argc, &argv);                /* Initialize MPI */
  MPI_Comm_size(MPI_COMM_WORLD, &np);    /* Get nr of processes */
  MPI_Comm_rank(MPI_COMM_WORLD, &me);    /* Get own identifier */
  
  /* Check that we have one process for each row in the matrix */
  if (np != LENGTH) {
    if (me == 0) {
      printf("You have to use %d processes\n", LENGTH);
    }
    MPI_Finalize();
    exit(0);
  }

  /* Allocate memory for the sendcount and displacements arrays */
  sendcount = (int *)malloc(LENGTH*sizeof(int));
  displs1 = (int *)malloc(LENGTH*sizeof(int));

  /* Initialize sendcount and displacements arrays */
  for (i=0; i<LENGTH; i++) {
    sendcount[i] = i+1;
    displs1[i] = i*LENGTH;
  }

  if (me == 0) {    /* Process 0 does this */
    /* Initialize the matrix x with values 0 .. LENGTH*LENGTH-1 */
    for (i=0; i<LENGTH; i++) {
      for (j=0; j<LENGTH; j++) {
	x[i][j] = i*LENGTH+j;
      }
    }
    /* Print out the matrix before it is distributed */
    printf("The initial matrix is\n");
    for (i=0; i<LENGTH; i++) {
      for (j=0; j<LENGTH; j++) {
	printf("%4d ", x[i][j]);
      }
      printf("\n");
    }
  }
    
    /* Scatter the lower triangular part of array x to all proceses, place it in y */
    MPI_Scatterv(&x, sendcount, displs1, MPI_INT, &y, sendcount[me], MPI_INT, root, MPI_COMM_WORLD);

	if (me==0) {
    /* Initialize the result matrix res with values 0 */
    for (i=0; i<LENGTH; i++) {
      for (j=0; j<LENGTH; j++) {
	res[i][j] = 0;
      }
    }
    /* Print out the result matrix res before gathering */
    printf("The result matrix before gathering is\n");
    for (i=0; i<LENGTH; i++) {
      for (j=0; j<LENGTH; j++) {
	printf("%4d ", res[i][j]);
      }
      printf("\n");
    }
	}

    /* Allocate memory for the recvcount and displacements arrays */
    recvcount = (int *)malloc(LENGTH*sizeof(int));
    displs2 = (int *)malloc(LENGTH*sizeof(int));
	
	for (i=0; i<LENGTH; i++) {
      recvcount[i] = i+1;
      displs2[i] = i*LENGTH;
	}
	
	/* Gather the local elements of each process to form a triangular matrix in the root */
    MPI_Gatherv(&y, recvcount[me], MPI_INT, &res, recvcount, displs2, MPI_INT, root, MPI_COMM_WORLD);

	if (me == 0) {    /* Process 0 does this */
    /* Print out the result matrix after gathering */
    printf("The result matrix after gathering is\n");
    for (i=0; i<LENGTH; i++) {
      for (j=0; j<LENGTH; j++) {
	printf("%4d ", res[i][j]);
      }
      printf("\n");
    }
  }
  
  MPI_Finalize();
}




