#include <stdio.h>
#include "mpi.h"

main(int argc, char** argv)  
{
   int my_rank;
   int p,k,res,finres,num;
   int source,target;
   int tag1=50, tag2=60, tag3=70;
   int plithos;
   int data[100];
   int data_loc[100];
   MPI_Status status;

   MPI_Init(&argc, &argv);
   MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
   MPI_Comm_size(MPI_COMM_WORLD, &p);

   if (my_rank == 0)  {
       printf("Dose plithos aritmon:\n");
       scanf("%d", &plithos);
       printf("Dose tous %d arithmous:\n", plithos); 
       for (k=0; k<plithos; k++)
            scanf("%d", &data[k]);
       for (target = 1; target < p; target++) 
           MPI_Send(&plithos, 1, MPI_INT, target, tag1, MPI_COMM_WORLD);
      num = plithos/p;  k=num;
      for (target = 1; target < p; target++)  {
         MPI_Send(&data[k], num, MPI_INT, target, tag2, MPI_COMM_WORLD);
         k+=num;  }
      for (k=0; k<num; k++)
         data_loc[k]=data[k];
     }
   else  {
       MPI_Recv(&plithos, 1, MPI_INT, 0, tag1, MPI_COMM_WORLD, &status);
       num = plithos/p;
       MPI_Recv(&data_loc[0], num, MPI_INT, 0, tag2, MPI_COMM_WORLD, &status);
     }

   res = 0;
   for (k=0; k<num; k++)
        res = res + (data_loc[k]*data_loc[k]);

   if (my_rank != 0)  {
       MPI_Send(&res, 1, MPI_INT, 0, tag3, MPI_COMM_WORLD);
    }
   else  {
       finres = res;
       printf("\n Apotelesma of process %d: %d\n", my_rank, res);
       for (source = 1; source < p; source++)  {
           MPI_Recv(&res, 1, MPI_INT, source, tag3, MPI_COMM_WORLD, &status);
           finres = finres + res;
           printf("\n Apotelesma of process %d: %d\n", source, res);
        }
    printf("\n\n\n Teliko Apotelesma: %d\n", finres);
   }

   MPI_Finalize();
} 

