#include "mpi.h"
#include <stdio.h>

int main(argc,argv)
	int argc;
	char *argv[];
{
	int numtasks, rank, rc;

	rc = MPI_Init(&argc,&argv);
	if(rc!=0)
	{
		printf("MPI Initialization error\n");
		MPI_Abort(MPI_COMM_WORLD,rc);
	}

	MPI_Comm_size(MPI_COMM_WORLD,&numtasks);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	printf("Number of processes = %d My rank = %d\n",numtasks,rank);

	MPI_Finalize();
	
	return 0;
}
