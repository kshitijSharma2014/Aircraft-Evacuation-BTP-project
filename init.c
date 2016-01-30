#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include"Passenger.h"
#include"Aircraft.h"

//this structure defines a block (it can be an exit block or a aisle block thats all 
//it also stores the id of the passenger residing on that block)


typedef struct block
{
int occ;
int passid;	
int exit;
	}block;



int main()
{
  srand(time((0)));
  Aircraft* air= input();
  int numPass,i,j;
  scanf("%d",&numPass);
  Passenger* P = pass_input(numPass);
	
	// Seating Arrangement Assigning Each Passenger location to sit randomely
	// Think something to make sure the random function does not send it to infinite loop
	
	int seat[100][100];
	for(i=0;i<100;++i)
	{
		for(j=0;j<100;++j)
			seat[i][j]=0;
	}

	//all seats are vacant right now

	int r_row,r_col;
	for(i=0;i<numPass;++i)
	{
		int r_row=rand()%30;
		int r_col=rand()%6;
		if(seat[r_row][r_col]==0)
			{
					P[i].x=r_row;
					P[i].y=r_col;
			}
		else
		{
				i--;
			}
		
	}
	// Now each row is occupied by some passengers 
	// Each passenger is sitting in a row and each row is having corresponding aisle array portion in front of it.
	// The passenger can move to the aisle A[] in front of its row if it is unoccupied


	block A[100000];
	// A is the aisle
	//Each Element of the 
	for(j=0;j<100000;++j)
		{	
				A[i].occ=0;
				A[i].passid=-1;
				A[i].exit=0;
		}
	// the aisle is empty right now
	//Now there are 4 Normal Gate Exits and 
	//Exit Paths are of 2 types 1 end and other in the middle each one will have different speeds
	

	block B[4][55]; // Nornal Exit Paths 2 on each ends of the plane
	block C[4][55]; // Seat Exit 2 in the middle of the plane
	
	for(i=0;i<4;++i)
	{
		for(j=0;j<55;++j)
			{
				B[i][j].occ=0;
				C[i][j].occ=0;
				B[i][j].passid=-1;
				C[i][j].passid=-1;
				B[i][j].exit=0;
				C[i][j].exit=0;
				
				
				}
		}

	// Here the game starts
	//Emergency! Emergency! Emergency! Run all of you Out of the plane

		
	  return 0;
}
