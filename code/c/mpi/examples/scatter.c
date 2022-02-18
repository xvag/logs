#include <stdio.h>
#include "mpi.h"

int main(int argc, char** argv)
{
int my_rank;
int p, k;
int b, size;
int root;
int matrixA[100];
int loc_num;
int loc_matrix[100];
int loc_res[100];
int final_res[100];
int namelen;
char proc_name[MPI_MAX_PROCESSOR_NAME];

MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
MPI_Comm_size(MPI_COMM_WORLD, &p);
MPI_Get_processor_name(proc_name, &namelen);

if (my_rank == 0)  
 {
   printf("YPOLOGISMOS THS PARASTASHS b * A \n\n");
   printf("DOSE THN TIMH TOY B:\n"); 
   scanf("%d", &b);
   printf("DOSE TO MHKOS TOY PINAKA A:\n"); 
   scanf("%d", &size);
   printf("DOSE TA STOIXEIA TOY PINAKA A MHKOYS %d:\n", size); 
   for (k=0; k<size; k++)
         scanf("%d", &matrixA[k]);
  }

root = 0;
MPI_Bcast(&size, 1, MPI_INT, root, MPI_COMM_WORLD);
MPI_Bcast(&b, 1, MPI_INT, root, MPI_COMM_WORLD);

loc_num = size/p;

root = 0; 
MPI_Scatter(matrixA, loc_num, MPI_INT, loc_matrix, loc_num, MPI_INT, root, MPI_COMM_WORLD);

for (k=0; k<loc_num; k++)
    loc_res[k] = b*loc_matrix[k];

printf("\n Process %d on %s : local results are :  ", my_rank, proc_name);
for (k=0; k<loc_num; k++) printf("%d ", loc_res[k]);
printf("\n\n");

root = 0;
MPI_Gather(loc_res, loc_num, MPI_INT, final_res, loc_num, MPI_INT, root, MPI_COMM_WORLD);

if (my_rank == 0)  
 {
    printf("\n TELIKO APOTELESMA  %d *  A =\n", b); 
    for (k=0; k<size; k++) printf("%d ", final_res[k]); 
    printf("\n\n");
  }

MPI_Finalize();
return 0;
}

