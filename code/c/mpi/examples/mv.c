#include <stdio.h>
#include <mpi.h>
#define N 10 

main(int argc, char **argv) {
	int j,k,A_loc;
	int rank,size,root;
	int A[N];
	int B_loc[N];
	int C[N];
	int B[N][N];
	
MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Comm_size(MPI_COMM_WORLD, &size);

root = 0;

/* Αρχικοποίησε τους πίνακες Β και C */

if (rank == root) 
  {

    for (k=0; k<N; k++) 
       for (j=0; j<N; j++) 
           B[k][j] = k+j;

    for (k=0; k<N; k++) 
           C[k] = k;
  }

/* Διαμοίρασε τον πίνακα B κατά γραμμές με χρήση της MPI_Scatter */

MPI_Scatter(B, N, MPI_INT, B_loc, N, MPI_INT, root, MPI_COMM_WORLD);

/* Στείλε σε όλες το διάνυσμα C με χρήση της MPI_Bcast */

MPI_Bcast(C, N, MPI_INT, root, MPI_COMM_WORLD);

/* Κάνε τους απαραίτητους τοπικούς πολλαπλασιασμούς και προσθέσεις προκειμένου να υπολογίσεις το τοπικό σου στοιχείο του πίνακα Α */

for(j=0; j<N; j++)  
   A_loc += C[j]*B_loc[j];   
	
/* και συγκέντρωσε τα τελικά αποτελέσματα απλά με μία MPI_Gather */

MPI_Gather(&A_loc, 1, MPI_INT, A, 1, MPI_INT, root, MPI_COMM_WORLD);

/* τύπωσε το τελικό αποτέλεσμα */
if (rank == 0) 
 {
   for (k=0; k<N; k++) 
     printf("A[%d]=%d\n", k, A[k]);
 }

MPI_Finalize();
}
