#include <stdio.h>
#include "mpi.h"

int main(argc,argv) 
int argc;
char *argv[];
{
int numtasks, rank, dest, source, tag = 1;
char msg1[15], msg2[15];
MPI_Status stat;

MPI_Init(&argc,&argv);
MPI_Comm_size(MPI_COMM_WORLD, &numtasks);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    
sprintf(msg1, "Sample message");
    
if (rank == 0)  {
  dest = 1;
  source = 1;

  while (1)  {
  MPI_Send(msg1, 15, MPI_CHAR, dest, tag,  
           MPI_COMM_WORLD);
  sprintf(msg1, "\0");
  MPI_Recv(msg1, 15, MPI_CHAR, source, tag, 
           MPI_COMM_WORLD, &stat);   
  printf("Process %d Message = %s \n", rank, msg1);
  sleep(2);
  }
 } 

else if (rank == 1)  {
  dest = 0;
  source = 0;

  while (1)  {
    sprintf(msg2, "\0");
    MPI_Recv(msg2, 15, MPI_CHAR, source, tag, 
             MPI_COMM_WORLD, &stat);
    printf("Process %d Message = %s \n", rank, msg2);
    sleep(2);
    MPI_Send(msg2, 15, MPI_CHAR, dest, tag, 
             MPI_COMM_WORLD); 
  }
 }

 MPI_Finalize();
}

