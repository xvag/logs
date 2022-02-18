#include "stdio.h"
#include "mpi.h"
void main(int argc, char *argv[]) 
{
	int nrow, mcol, irow, jcol, Iam, me, ndim;
	int p, ierr, root, index, displ;
	int source1, source2, source3, source4, source5;
	int dest1, dest2, dest3, dest4, dest5;
	int coords[2], dims[2];
	int periods[2], reorder;
	MPI_Comm comm2D;
	MPI_Init(&argc, &argv);					
	MPI_Comm_rank(MPI_COMM_WORLD, &Iam);	
	MPI_Comm_size(MPI_COMM_WORLD, &p);		
    nrow = 3; mcol = 2; ndim = 2;
	root = 0; periods[0] = 1; periods[1] = 0; reorder = 1;
	if (Iam == root)
	{
		printf("        (         along the rows           )(   across columns     )\n");
		printf("          <== +1 ==>  <== -2 ==>  <== +3 ==>  <== +1 ==>  <== -1 ==>\n");
		printf("   2D   Row   Col  From    To  From    To  From    To  From    To  From    To\n");
		printf(" Rank     i     j   Src  Dest   Src  Dest   Src  Dest   Src  Dest   Src  Dest\n");
	}
	MPI_Barrier(MPI_COMM_WORLD);
	/* create cartesian topology for processes */
	dims[0] = nrow;		/* number of rows */
	dims[1] = mcol;		/* number of columns */
	MPI_Cart_create(MPI_COMM_WORLD, ndim, dims, periods, reorder, &comm2D);
	MPI_Comm_rank(comm2D, &me);
	MPI_Cart_coords(comm2D, me, ndim, coords);
 index = 0;	/* shift along the 1st direction (0; not 1) */
	displ = 1;	/* shift by  1 */
	MPI_Cart_shift(comm2D, index, displ, &source1, &dest1);
	index = 0;	/* shift along the 1st direction */
	displ = -2;	/* shift by -2 */
	MPI_Cart_shift(comm2D, index, displ, &source2, &dest2);
	index = 0;	/* shift along the 1st direction (0; not 1) */
	displ = 3;	/* shift by  3 */
	MPI_Cart_shift(comm2D, index, displ, &source3, &dest3);
	index = 1;	/* shift along the 2nd direction (1; not 2) */
	displ = 1;	/* shift by  1 */
	MPI_Cart_shift(comm2D, index, displ, &source4, &dest4);
	index = 1;	/* shift along the 2nd direction */
	displ = -1;	/* shift by -1 */
	MPI_Cart_shift(comm2D, index, displ, &source5, &dest5);

	printf("%5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d\n", me, coords[0], coords[1], source1, dest1, source2, dest2, source3, dest3, source4, dest4, source5, dest5);
	MPI_Finalize();	}
