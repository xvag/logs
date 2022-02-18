// This program reads n integers and stores them in vector X
// Then it calculates:
// the average m = x[0]+x[1]+x[2]+...+x[n-1])/n
// the diaspora var = ((x[0]-m)^2 + (x[1]-m)^2 + (x[2]-m)^2 + ... + (x[n-1]-m)^2)/n
// and creates a new vector D with values: d[i] = ((x[i]-Xmin)/(Xmax-Xmin))*100

#include <stdio.h>
#include "mpi.h"

int main(int argc, char** argv)
{
	int tag1=10,tag2=20,tag3=30,tag4=40,tag5=50,tag6=60,tag7=70,tag8=80,tag9=90,tag10=100;
	int i, my_rank, rank;
	
	int p; // number of processors/nodes
	int n; // number of integers stored in vector X
	int nperp; // numbers per processor

	float m; // average
	float var; // diaspora
	int min,max; // min and max values of vector X

	int min_x[3]; // temporary tables for storing min and max values.
	int max_x[3]; // one position for every processor. supports up to 4 processors.

	int x[100]; // vector X
	float d[100]; // vector D

	MPI_Status status;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&my_rank);
	MPI_Comm_size(MPI_COMM_WORLD,&p);

	if(my_rank==0)
	{
		// Proc 0 reads number of integers and stores them in vector X.
		printf("Give number of elements for vector x:\n");
		scanf("%d",&n);
		printf("Give %d numbers:\n",n);
		for(i=0;i<n;i++)
			scanf("%d",&x[i]);

		// Proc 0 calculates numbers per processor and sends values to other
		// procs. 
		nperp=n/p;		
		for(rank=1;rank<p;rank++)
		{
			MPI_Send(&nperp,1,MPI_INT,rank,tag1,MPI_COMM_WORLD);
			MPI_Send(&x[rank*nperp],nperp,MPI_INT,rank,tag2,MPI_COMM_WORLD);
		}
	}
	else
	{
		// Other procs (not 0) receive values of nperp and the part of vector X
		// that they should use to make calculations.
		MPI_Recv(&nperp,1,MPI_INT,0,tag1,MPI_COMM_WORLD,&status);
		MPI_Recv(&x[my_rank*nperp],nperp,MPI_INT,0,tag2,MPI_COMM_WORLD,&status);
	}

	// Calculations executed by all procs
	int sum=0;
	int v=my_rank*nperp; // position in vector for each processor
	min_x[my_rank]=x[v];
	max_x[my_rank]=x[v];
	for(i=0;i<nperp;i++)
	{
		// Sum to be used for calculating Average.
		sum+=x[v+i];

		// Each proc finds min/max values for the portion of the vector X
		// that belongs to it and stores them in vectors min_x and max_x 
		// in the positions accordingly to their ranks.
		if(x[v+i]<min_x[my_rank])
			min_x[my_rank]=x[v+i];

		if(x[v+i]>max_x[my_rank])
			max_x[my_rank]=x[v+i];
	}
	// End of calculations executed by all procs
	

	if(my_rank!=0)
	{
		// Other procs (not 0) send their results.
		MPI_Send(&sum,1,MPI_INT,0,tag3,MPI_COMM_WORLD);
		MPI_Send(&min_x[my_rank],1,MPI_INT,0,tag6,MPI_COMM_WORLD);
		MPI_Send(&max_x[my_rank],1,MPI_INT,0,tag7,MPI_COMM_WORLD);
	}
	else
	{
		// Proc 0 initializes final values with its results.
		int finsum=sum;
		min=min_x[0];
		max=max_x[0];
		printf("Calculating average: Process %d: %d\n",my_rank,sum);
		printf("Calculating min/max: Process %d: min:%d max:%d\n",my_rank,min_x[0],max_x[0]);

		// Proc 0 receives results from other procs and produces the final results.
		for(rank=1;rank<p;rank++)
		{
			MPI_Recv(&min_x[rank],1,MPI_INT,rank,tag6,MPI_COMM_WORLD,&status);
			MPI_Recv(&max_x[rank],1,MPI_INT,rank,tag7,MPI_COMM_WORLD,&status);
			MPI_Recv(&sum,1,MPI_INT,rank,tag3,MPI_COMM_WORLD,&status);
			finsum=finsum+sum;
			printf("Calculating average: Process %d: %d\n",rank,sum);	
			printf("Calculating min/max: Process %d: min:%d max:%d\n",rank,min_x[rank],max_x[rank]);
			// Proc 0 calculates final min and max values.
			if(min_x[rank]<min)
				min=min_x[rank];
			if(max_x[rank]>max)
				max=max_x[rank];
		}
		
		// Proc 0 calculates final value of Average.
		m = (float) finsum/ (float) n;

		// Proc 0 prints final values.
		printf("\nAverage = %.2f\nMIN = %d\nMAX = %d\n\n",m,min,max);

		// Proc 0 sends final results of Average and min/max to other procs.
		for(rank=1;rank<p;rank++)
		{
			MPI_Send(&m,1,MPI_FLOAT,rank,tag4,MPI_COMM_WORLD);
			MPI_Send(&min,1,MPI_INT,rank,tag8,MPI_COMM_WORLD);
			MPI_Send(&max,1,MPI_INT,rank,tag9,MPI_COMM_WORLD);			
		}
	}

	if(my_rank!=0)
	{
		// Other procs (not 0) receive final results of Average and min/max values.
		MPI_Recv(&m,1,MPI_FLOAT,0,tag4,MPI_COMM_WORLD,&status);
		MPI_Recv(&min,1,MPI_INT,0,tag8,MPI_COMM_WORLD,&status);
		MPI_Recv(&max,1,MPI_INT,0,tag9,MPI_COMM_WORLD,&status);
	}		


	// Calculations executed by all procs
	float sum2=0.0;
	for(i=0;i<nperp;i++)
	{
		// Sum to be used for calculating Diaspora
		sum2+=(((float)x[v+i]-m)*((float)x[v+i]-m));
		// Creating vector D. Each proc manipulates different part of the vector.
		d[v+i]=(((float)x[v+i]-(float)min)/((float)max-(float)min))*100.0;
	}
	// End of calculations executed by all procs

	if(my_rank!=0)
	{
		// Other procs (not 0) send their results.
		MPI_Send(&sum2,1,MPI_FLOAT,0,tag5,MPI_COMM_WORLD);
		MPI_Send(&d[v],nperp,MPI_FLOAT,0,tag10,MPI_COMM_WORLD);
	}
	else
	{
		// Proc 0 initializes final value for diaspora with its result.
		float finsum2=sum2;
		printf("Calculating diaspora: Process %d: %.2f\n",my_rank,sum2);		
		// Proc 0 receives results from other procs and produces final results for diaspora.
		for(rank=1;rank<p;rank++)
		{
			MPI_Recv(&sum2,1,MPI_FLOAT,rank,tag5,MPI_COMM_WORLD,&status);
			MPI_Recv(&d[rank*nperp],nperp,MPI_FLOAT,rank,tag10,MPI_COMM_WORLD,&status);
			finsum2=finsum2+sum2;
			printf("Calculating Diaspora: Process %d: %.2f\n",rank,sum2);
		}
		// Proc 0 calculates and prints final value of Diaspora.
		var=finsum2/(float)n;
		printf("\nDiaspora = %.2f\n",var);

		// Proc 0 prints vector D.
		printf("\nVector D: \n");
		for(i=0;i<n;i++)
			printf("D[%d] = %.2f%\n",i,d[i]);

	}
	
	MPI_Finalize();
	return 0;
}
