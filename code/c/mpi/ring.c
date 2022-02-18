#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"

int main(int argc, char** argv)
{
	int rank;
	int size;

	MPI_Init(&argc,&argv);
	MPI_Status stat;

	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);

	int mes=100;

	MPI_Send(&mes,1,MPI_INT,(rank+1)%size,0,MPI_COMM_WORLD);	

	if(rank!=0)
	{
		MPI_Recv(&mes,1,MPI_INT,rank-1,0,MPI_COMM_WORLD,&stat);
		printf("proc %d received msg %d from proc %d\n",rank,mes,rank-1);
	}
	else
	{
		MPI_Recv(&mes,1,MPI_INT,size-1,0,MPI_COMM_WORLD,&stat);
		printf("proc %d received msg %d from proc %d\n",rank,mes,size-1);
	}

	MPI_Finalize();
	
	return 0;
}

