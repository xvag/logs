#include <stdio.h>
#include "mpi.h"

main(int argc, char** argv)
{
int my_rank;
int p, k, count;
int root;
int a1_local;
int a2_local;
int local_num;
int endnum;
int local_res[50];
int final_res[50];
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

local_num = endnum/p;
a1_local = (my_rank * local_num) + 1;
a2_local = a1_local + local_num - 1;
count=0;
for (k=a1_local; k<=a2_local; k++)
  {
   local_res[count] = (k*k);
   count++;
  }
printf("\n Process %d on %s : local squares are :  ", my_rank, proc_name);
for (k=0; k<local_num; k++) printf("%d ", local_res[k]);
printf("\n\n");

root = 0;
MPI_Gather(local_res, local_num, MPI_INT, final_res, local_num, MPI_INT, root, MPI_COMM_WORLD);

if (my_rank == 0)  
 {
   printf("\n The %d squares are the following: ", endnum);
   for (k=0; k<endnum; k++) printf("%d ",final_res[k]);
   printf("\n\n");
  }

MPI_Finalize();
}



