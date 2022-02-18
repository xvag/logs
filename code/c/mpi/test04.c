#include <stdio.h>
#include <string.h>
#include "mpi.h"

int main(int argc, char **argv)
{
	char msg[20];
	int process_rank,tag=100;
	MPI_Status status;

	MPI_Init(&argc,&argv);

	MPI_Comm_rank(MPI_COMM_WORLD,&process_rank);
	if (process_rank==0)
	{
		strcpy(msg,"Hello World");
		MPI_Send(msg,strlen(msg)+1,MPI_CHAR,1,tag,MPI_COMM_WORLD);
	}
	else if (process_rank==1)
	{
		MPI_Recv(msg,20,MPI_CHAR,0,tag,MPI_COMM_WORLD,&status);
		printf("Process 1 message = %s\n",msg);
	}

	MPI_Finalize();

	return 0;
}
