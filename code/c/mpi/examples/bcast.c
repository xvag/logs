#include <stdio.h>
#include "mpi.h"

main(int argc, char** argv)
{
int my_rank;
int p, k;
int root;
int a1_local;
int a2_local;
int local_num;
int endnum;
int local_res;
int final_res;
int namelen;
char proc_name[MPI_MAX_PROCESSOR_NAME];

MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
MPI_Comm_size(MPI_COMM_WORLD, &p);
MPI_Get_processor_name(proc_name, &namelen);

if (my_rank == 0)  
 {
   printf("Dose plithos arithmvn:\n"); 
   scanf("%d", &endnum);
  }

root = 0;
MPI_Bcast(&endnum, 1, MPI_INT, root, MPI_COMM_WORLD);

local_res = 0;
local_num = endnum/p;
a1_local = (my_rank * local_num) + 1;
a2_local = a1_local + local_num - 1;
for (k=a1_local; k<=a2_local; k++)
   local_res = local_res + (k*k);
printf("\n Process %d on %s : local result = %d \n", my_rank, proc_name, local_res);

root = 0;
MPI_Reduce(&local_res, &final_res, 1, MPI_INT, MPI_SUM, root, MPI_COMM_WORLD);

if (my_rank == 0)  
 {
   printf("\n Total result for N = %d is equal to : %d \n", endnum, final_res); 
  }

MPI_Finalize();
}


