#include <stdio.h>
#include "mpi.h"

main(int argc, char** argv)
{
int my_rank;
int k, p;
int threshold;
int root;
int local_max;
int total_max;
int data[10];
int namelen;
char proc_name[MPI_MAX_PROCESSOR_NAME];

MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
MPI_Comm_size(MPI_COMM_WORLD, &p);
MPI_Get_processor_name(proc_name, &namelen);

for (k=0; k<10; k++)
data[k]=my_rank+k;

if (my_rank == 0)  
 {
   printf("Dose ena orio anazitisis:\n"); 
   scanf("%d", &threshold);
  }

root = 0;
MPI_Bcast(&threshold, 1, MPI_INT, root, MPI_COMM_WORLD);
  
local_max = 0;
for (k=0; k<10; k++)
    { 
      if ((data[k] > threshold) && (data[k] > local_max))  local_max=data[k]; 
    }
printf("\n Process %d on %s : local maximum = %d \n", my_rank, proc_name, local_max);

root = 0;
MPI_Reduce(&local_max, &total_max, 1, MPI_INT, MPI_MAX, root, MPI_COMM_WORLD);

if (my_rank == 0)  
 {
   if (total_max > threshold) 
       printf("\n Maximum number found for threshold %d is equal to : %d \n", threshold, total_max); 
   else
       printf("\n No number found greater than threshold %d \n", threshold); 
   }

MPI_Finalize();
}

