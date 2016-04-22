  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #include"Passenger.h"
  #include"Aircraft.h"

  //this structure defines a block (it can be an exit block or a aisle block thats all
  //it also stores the id of the Passenger residing on that block)


  typedef struct block
  {
  	//Now more occ as it is useless
  int passid;	// -1 means unoccupied or Pasengerid
  int exit; // if this one is exit one
  	}block;



  // Delta z value is 1 inch so each row has 30 inch of aile length in front of it
  //
void printToFile(char filename[], int a[]);
  void pass_input(Passenger P[],int n);
void createGlobalMatrix(int h_seat[100][100], block h_A[1000], block h_B[4][55], block h_C[4][55], char filename[50],float tt);
Aircraft aircraftInput(char name[]);
  __device__ void get_Aisle_Range(int range[],int i, int N)
  {

    if(i>=1 && i<=N/2 - 1)
    {
      range[0] = (i-1)*30;
      range[1] = range[0] +30 - 1;
    }
    else if(i == N/2)
    {
      range[0] = (i-1)*30;
      range[1] = range[0] + 50 -1;
    }
    else if(i == N/2 + 1)
    {
	range[0] = (i-2)*30 + 50;
	range[1] = range[0] + 50 -1;
    }
    else if(i>N/2+1 && i<=N-1)
    {
      range[0] = (i-1)*30+40;
      range[1] = range[0] +30 - 1;
    }
  //return range;
  }





/*
  __device__ int select_exit(Passenger P, int exit[])
  {
      int ans =0;
      if ((exit[0] == 1 || exit[1] == 1) && (exit[2]==1 || exit[3]==1 || exit[4]==1 || exit[5]==1) && P.x<=470){
          if(P.x<470-P.x)
          {
              ans = (exit[0] == 1) ? 0:1;
          }
          else{
              if(exit[2]==1 || exit[3]==1){
                  ans = (exit[2] == 1) ? 2:3;
              }
              else if(exit[4]==1 || exit[5]==1){
                  ans = (exit[4] == 1) ? 4:5;
              }
          }
      }
      else if ((exit[6] == 1 || exit[7] == 1) && (exit[2]==1 || exit[3]==1 || exit[4]==1 || exit[5]==1) && P.x>470){
          if(940-P.x<P.x-470){
              ans = (exit[6] == 1) ? 6:7;
          }
          else{
              if(exit[4]==1 || exit[5]==1){
                  ans = (exit[4] == 1) ? 4:5;
              }
              else if(exit[2]==1 || exit[3]==1){
                  ans = (exit[2] == 1) ? 2:3;
              }
          }

      }
      return ans;
  }

*/
__device__ int select_exit(Passenger P, int exit[])
  {
      int i,ans =-1;
      if(P.x<470)
      {
        if(P.x<470-P.x)
        {
          if(exit[0]==1||exit[1]==1)
            ans=0;
        }
        else
        {
          if(exit[2]==1||exit[3]==1||exit[4]==1||exit[5]==1)
            ans=3;
        }
      }
      else
      {
        if(940-P.x<P.x-470)
        {
          if(exit[7]==1||exit[8]==1)
            ans=7;
        }
        else
        {
          if(exit[2]==1||exit[3]==1||exit[4]==1||exit[5]==1)
            ans=3;
        }
      }
      if(ans==-1)
      {
        for(i=0;i<6;++i)
          {
            if(exit[i]==1)
              return i;
          }
      }
      else
        return ans;
  }


  __device__ int get_direction(Passenger p, block A[], int exitnum){
      if(exitnum == 0 || exitnum == 1){
          if(p.x-4 > 0){
              return 1;
          }
          else if(p.x-4 <= 0){
              return 0;
          }
      }
      else if (exitnum == 6 || exitnum == 7)
      {
          if(p.y+4 < 940){
              return -1;
          }
          else if(p.y >= 940){
              return 0;
          }
      }
      else if ((exitnum == 2 || exitnum == 3))
      {
          if(p.x < 450){
              return -1;
          }
          if(p.x > 500){
              return 1;
          }
          if(p.x >= 450 || p.x <= 500){
              return 0;
          }
      }
      else if ((exitnum == 4 || exitnum == 5))
      {
          if(p.x < 500){
              return -1;
          }
          if(p.x > 550){
              return 1;
          }
          if(p.x >= 500 || p.x <= 550){
              return 0;
          }
      }
      return 0;
  }
 /*
  __global__ void map_Passenger_to_exit(Passenger P[], int seat[100][100], block C[][55],int exit[]){

    int k,j,m,i =2, rownm;

    while(i<6 && exit[i]!=0){
      if(i==2)
      {
          rownm = 15;
          j=0;
      }
      if(i==3)
      {
          rownm = 15;
          j=5;
      }
      if(i==4)
      {
          rownm = 16;
          j=0;
      }

      if(i==5){
          rownm = 16;
          j=5;
      }
      for(k=0;k<35;){

          for( m = k; m < k + (int)P[ seat[rownm][j] ].diameter ; ++m){
              C[i-2][m].passid = seat[rownm][j];
          }
          seat[rownm][j] = 0;
          //C[i-2][p[seat[rownm][j]].diameter-1].passid = -1*seat[rownm][j];
          if(i==2 || i==4){
              ++j;
          }
          else if(i==3 || i==5){
              --j;
          }
          k=k+17;
      }
      ++i;
    }
  }
*/



    __global__ void movement_to_exit(block A[],block B[4][55],block C[4][55],Passenger P[] ,int seat[][100],int d_exit[],int numPass) //runs for each Passenger and make his movmenent according to the positions
    {
    // Now we have to map the thread id with the passennger id

    int i=threadIdx.x,k;
    int range[2];
    int j,count=0;
    int tex,ex,dir;
  //  int exit[]={1,1,0,0,1,1,0,0};

    if(i < numPass)
    {
     switch(P[i].status)
     {
      //printf("Hello\n" );
     	case 0: //the Passenger is in his seat aisle (x=row  number y = (1-6)column in seat )
        if(P[i].y == 2 || P[i].y==3)
     		{

    			get_Aisle_Range(range, P[i].x , 30);
    		//	range[0]=0;
         // range[1]=50;
          count=0;
    			for(j=range[0];j<range[1];++j)
    				{
    					if(A[j].passid == -1)
    					{
    						count++;
    						if(count >= P[i].diameter)
    							break;
    					}
    					else
    						count=0;
    				}

    				if(j<range[1]+1)
    				{

    					for(k=j;k>=j-P[i].diameter;--k)
    						A[k].passid=i;
    					seat[P[i].x][P[i].y]=-1;
              P[i].x=k;
    					P[i].y=j;
    					P[i].status=1;
              P[i].res=0;
    				}
        }
     		else
     			{
     				if(P[i].y < 2)
     				{
     					if(seat[P[i].x][P[i].y+1]==-1)
     						{
     				     if(P[i].res==60)
            			{
                    P[i].y++;
     							seat[P[i].x][P[i].y-1]=-1;
     							seat[P[i].x][P[i].y] = i;//
     						   P[i].res=0;
                  }
                  else
                    P[i].res++;
              }

     				}
     				else
     				{
     					if(seat[P[i].x][P[i].y-1]==-1)
     						{
                  if(P[i].res==60)
                  {
     							  P[i].y--;
     							  seat[P[i].x][P[i].y+1]=-1;
     							  seat[P[i].x][P[i].y] = i;//
     						   P[i].res=0;
                  }
                  else
                    P[i].res++;
                }

     				}
     			}
     	break;


    //comment starts here:
     	case 1:
     		//	the Passenger is in aisle and here the  x value that tell the starting of the Passenger
     		//  y   is the ending point of the Passenger
     		//	Select the exit and try to move towards the aisle point of that exit

        ex = select_exit(P[i], d_exit); // Create an exit array that contain 0 if the exit is not open and 1 if it is open
     		dir= get_direction(P[i],A,ex);

        P[i].ans=ex;
        P[i].dir=dir;

        if(dir == 1)
     		{

     			//move up
     			if(A[P[i].x-1].passid == -1 || A[P[i].x-2].passid == -1 || A[P[i].x-3].passid == -1 || A[P[i].x-4].passid == -1)
     			{
     				if(P[i].speed!=0.0f)
     				{
              if(P[i].res==2)
              {
     					  P[i].x-=2*P[i].speed;
     					  P[i].y-=2*P[i].speed;

                for (int s = 0; s < 2*P[i].speed; ++s)
                {
                  A[P[i].x + s].passid = i;
                  A[P[i].y+1+s].passid = -1;
                }

     				   P[i].res=0;
             }
             else
              P[i].res++;
            }
      			}
            else
                P[i].res=0;
      			//else dont move
     		}
     		else
     		{
     			if(dir==-1)
     			{
     				//move down
     				if(A[P[i].y+1].passid == -1 || A[P[i].y+2].passid == -1 || A[P[i].y+3].passid == -1 || A[P[i].y+4].passid == -1)
     				{
     					if(P[i].speed!=0.0f)
     					{
                if(P[i].res==2)
                {


                  P[i].x-=2*P[i].speed;
                  P[i].y-=2*P[i].speed;

                  for (int s = 0; s < 2*P[i].speed; ++s)
                  {
                    A[P[i].y - s].passid = i;
                    //A[P[i].x+1].passid = i;

                    A[P[i].x - 1 - s].passid = -1;
                    //A[P[i].y+2].passid = -1;
                  }
                  P[i].res=0;
     					  }
                else
                  P[i].res++;
              }
      			}
              else
                P[i].res=0;

     			}
     			else
     			{
            P[i].res=0;
     				//stay and jump to B or C
     				if(ex==0||ex==1||ex==6||ex==7)
     				{
     					//Going to B
              tex=ex;
     					if(ex==6||ex==7)
     						tex=ex-5;

              // Going to B[tex]

     					for(j=50;B[tex][j].passid==-1&&j> 50-P[i].diameter ;--j);

     					if(50 - j == P[i].diameter)
     					{
     						for(k=P[i].x;k<=P[i].y;++k)
                  A[k].passid=-1;
                P[i].x = tex;
     						P[i].y = j;

     					for(;j<=50;++j)
     						B[tex][j].passid=i;
              P[i].status=2;
     				 }
            }
     				else
     				{
              P[i].res=0;
                tex=ex-2;

              // Going to C[tex]

              for(j=50;C[tex][j].passid==-1&&j>50-P[i].diameter;--j);

              if(50 - j == P[i].diameter)
              {
                for(k=P[i].x;k<=P[i].y;++k)
                  A[k].passid=-1;
                P[i].x = tex;
                P[i].y = j;

              for(;j<=50;++j)
                C[tex][j].passid=i;
              P[i].status=3;
            }
     				}
     			}

     		}
     	break;


      case 2: // the Passenger is in midle of the exit front and end exit aisles i.e seat exit y represent the position in the aisle and
     		// x represent which aisle 1 / 2 / 3 / 4
     		if(P[i].y <= 0 && P[i].speed != 0.0f &&  (P[i].y-1 <= 0 || P[i].y-2 <= 0 || P[i].y-3 <= 0 || P[i].y-4 <= 0))
     		{
     	    for(j=0;j<10; ++j)
            {
              if(B[P[i].x][j].passid ==i)
                B[P[i].x][j].passid=-1;
          }
          P[i].status = 4; //Passenger is out of the plane
      	}
     		else
     		{

     			if(P[i].speed != 0.0f)
     			{
    				if(B[P[i].x][P[i].y-1].passid ==-1 || B[P[i].x][P[i].y-2].passid ==-1 || B[P[i].x][P[i].y-3].passid ==-1 || B[P[i].x][P[i].y-4].passid ==-1)
    				{
    	 				//move closer to the exit

    					P[i].y-=2*P[i].speed;

              for (int s = 0; s < 2*P[i].speed; ++s)
              {
                B[P[i].x][P[i].y + s].passid = i;
                B[P[i].x][(P[i].y + (int)P[i].diameter + 1 +s)].passid =-1;
              }
    	 			}
    	 		}
     		}

     	break;
     	case 3: // the Passenger is in middle of the middle exit aisles i.e seat exit y represent the position in the aisle and
     		// x represent which aisle 1 / 2 / 3 / 4
     	if(P[i].y <= 0 && P[i].speed != 0.0f && (P[i].y-1 <= 0 || P[i].y-2 <= 0 || P[i].y-3 <= 0 || P[i].y-4 <= 0))
     		{
     			for(j=0;j<10; ++j)
     				{
              if(C[P[i].x][j].passid ==i)
                C[P[i].x][j].passid=-1;
     			}
          P[i].status = 4; //Passenger is out of the plane
     		}
     		else
     		{

     			if(P[i].speed != 0.0f)
     			{
    				if(C[P[i].x][P[i].y-1].passid ==-1 || C[P[i].x][P[i].y-2].passid ==-1 || C[P[i].x][P[i].y-3].passid ==-1 || C[P[i].x][P[i].y-4].passid ==-1)
    				{
    	 				//move closer to the exit
    	 			 if(P[i].res==1)
             {
            	P[i].y-=2*P[i].speed;
              for (int s = 0; s < 2*P[i].speed; ++s)
              {
                C[P[i].x][P[i].y + s].passid = i;
                C[P[i].x][(P[i].y + (int)P[i].diameter + 1 +s)].passid =-1;
              }
            }
            else
              P[i].res++;
    	 			}
            else
              P[i].res=0;
    	 		}
     		}

     	break;
      case 4:
        P[i].x=-1;
        P[i].y=-1;
     };
    }
    }




void map_Passenger_to_exit(Passenger P[],int seat[][100], block C[][55],block B[][55],int h_exit[])
{
  int i,k,j,l;
  for(l=2;l<6;++l)
  {
    if(h_exit[l]==1)//the middle exit 2,3,4,5
    {
      if(l%2==0)
        {
          for(i=0;i<3;i++)
          {
            k=seat[15+(l-2)/2][i];
            if(k!=-1)
              {
                for(j=0;j<P[k].diameter;++j)
                  C[l-2][i*17 + j].passid=k;

                P[k].x=l-2;
                P[k].status = 3;
                P[k].y= i*17;
                P[k].res=0;
              }
            }
        }
        else
        {
          for(i=3;i<6;i++)
          {
            k=seat[15+(l-2)/2][i];
            if(k!=-1)
              {
                for(j=0;j<P[k].diameter;++j)
                  C[l-2][(5-i)*17 + j].passid=k;

                P[k].x=l-2;
                P[k].status = 3;
                P[k].y= (5-i)*17;
                P[k].res=0;
              }
            }
        }

    }
  }

}


//normal adjustment
int seatArrangement1(Passenger *h_P, int h_seat[][100], int numPass){
int r_row,r_col,i;
    for(i=0;i<numPass;++i)
    {
      r_row=rand()%30;   //should be defined in the header file TODO
      r_col=rand()%6;     //should be defined in the header file TODO
      if(h_seat[r_row][r_col]==-1)
        {
            h_P[i].x=r_row;
            h_P[i].y=r_col;
            if(r_row<0||r_col<0)
              {
                printf("Olala\n");
                return 0;
              }
            else
              h_seat[r_row][r_col]=i;
            printf("%d %d\n",r_row,r_col);
        }
      else
      {
          i--;
        }
    }
	return 1;
}

//older people in the aisle and younger in the window side
int seatArrangement2(Passenger *h_P, int h_seat[][100], int numPass){
  int r_row,r_col,i = 0,j =0;
      int oldPpl[100],youngPpl[100], k=0, l=0;
      for (i = 0; i < numPass;++i)
      {
        if (h_P[i].age > 40)
        {
          oldPpl[k] = i;
          ++k;
        }
        else{
          youngPpl[l] = i;
          ++l;
        }
      }
      int m =0, n=0;
      for (i = 0; i < 30; ++i)
      {
        for (j = 0; j < 6; ++j)
        {
          if (j%2 !=0 || j%3 == 0)
          {
            if(m<l)
            {
              h_P[youngPpl[m]].x = i;
              h_P[youngPpl[m]].y = j;
              h_seat[i][j] = youngPpl[m];
              ++m;
            }
          }
          else{
            if(n<k)
            {
              h_P[oldPpl[n]].x = i;
              h_P[oldPpl[n]].y = j;
              h_seat[i][j] = oldPpl[n];
              ++n;
            }
          }
        }
      }
    }
  return 1;
}

//younger people in the ailse and older in the window side
int seatArrangement3(Passenger *h_P, int h_seat[][100], int numPass){
int r_row,r_col,i = 0,j =0;
      int oldPpl[100],youngPpl[100], k=0, l = 0;
      for (i = 0; i < numPass;++i)
      {
        if (h_P[i].age > 40)
        {
          oldPpl[k] = i;
          ++k;
        }
        else{
          youngPpl[l] = i;
          ++l;
        }
      }
      int m = 0, n=0;
      for (i = 0; i < 30; ++i)
      {
        for (j = 0; j < 6; ++j)
        {
          if (j%2 !=0 || j%3 == 0)
          {
            if(m<k)
            {
              h_P[oldPpl[m]].x = i;
              h_P[oldPpl[m]].y = j;
              h_seat[i][j] = oldPpl[m];
              ++m;
            }
          }
          else{
            if(n<l)
            h_P[youngPpl[n]].x = i;
            h_P[youngPpl[n]].y = j;
            h_seat[i][j] = youngPpl[n];
            ++n;
          }
        }
      }
    }
  return 1;
}

// women in one half and men in second half
int seatArrangement4(Passenger *h_P, int h_seat[][100], int numPass){
  int r_row,r_col,i = 0,j =0;
      int women[100], men[100], k=0, l = 0;
      for (i = 0; i < numPass;++i)
      {
        if (h_P[i].sex == 0)
        {
          women[k] = i;
          ++k;
        }
        else{
          men[l] = i;
          ++l;
        }
      }

    for(i=0;i<k;++i)
    {
      r_row=rand()%15;
      r_col=rand()%6;
      if(h_seat[r_row][r_col]==-1)
        {
            h_P[women[i]].x=r_row;
            h_P[women[i]].y=r_col;
            if(r_row<0||r_col<0)
              {
                printf("Olala\n");
                return 0;
              }
            else
              h_seat[r_row][r_col]=i;
            //printf("%d %d\n",r_row,r_col);
        }
      else
      {
          i--;
        }
    }

    for(i=0;i<l;++i)
    {
      r_row=(rand()%15) + 15;
      r_col=rand()%6;
      if(h_seat[r_row][r_col]==-1)
        {
            h_P[men[i]].x=r_row;
            h_P[men[i]].y=r_col;
            if(r_row<0||r_col<0)
              {
                printf("Olala\n");
                return 0;
              }
            else
              h_seat[r_row][r_col]=i;
            //printf("%d %d\n",r_row,r_col);
        }
      else
      {
          i--;
        }
    }
return 1;
}

  //Main
  int main()
  {
    srand(time((0)));
    Aircraft air;
    char name[20];	
    printf("enter the name of the aircraft : ");
	scanf("%s",&name);
    air = aircraftInput(name);
   // printf("details aircraft:::row row %d ",air.row);
    int numPass,i,j;
    int count1=0;
printf("\n enter the number of passengers : ");
    scanf("%d",&numPass);
    Passenger *h_P =(Passenger *)malloc(sizeof(Passenger)*numPass);
    Passenger *P;


    pass_input(h_P,numPass);

  	// Seating Arrangement Assigning Each Passenger location to sit randomely
  	// Think something to make sure the random function does not send it to infinite loop

  	int h_seat[100][100];
  	int (*seat)[100];

  	for(i=0;i<100;++i)
  	{
  		for(j=0;j<100;++j)
  			h_seat[i][j]=-1;
  	}

  	//all seats are vacant right now
	int tt = seatArrangement1(h_P, h_seat, numPass);
  	if(tt == 0){
		return 0;
	}

  /*
    for(i=0;i<30;++i)
    {
      for(j=0;j<10;++j)
        printf("%d ",h_seat[i][j]+1);
      printf("\n");
    }
*/


  	// Now each row is occupied by some Passengers
  	// Each Passenger is sitting in a row and each row is having corresponding aisle array portion in front of it.
  	// The Passenger can move to the aisle A[] in front of its row if it is unoccupied
  printf("Seating Done\n");

  	block h_A[1040];
  	block* A;


  	// A is the aisle
  	//Each Element of the
  	for(j=0;j<1040;++j)
  		{
  				h_A[j].passid=-1;
  				h_A[j].exit=0;
  		}
  	// the aisle is empty right now
  	//Now there are 4 Normal Gate Exits and
  	//Exit Paths are of 2 types 1 end and other in the middle each one will have different speeds


  	block h_B[4][55]; // Nornal Exit Paths 2 on each ends of the plane
  	block h_C[4][55]; // Seat Exit 2 in the middle of the plane

  	block (*B)[55]; // Nornal Exit Paths 2 on each ends of the plane
  	block (*C)[55]; // Seat Exit 2 in the middle of the plane

  	for(i=0;i<4;++i)
  	{
  		for(j=0;j<55;++j)
  			{
  				h_B[i][j].passid=-1;
  				h_C[i][j].passid=-1;
  				h_B[i][j].exit=0;
  				h_C[i][j].exit=0;
  			}
  	}

  	// set up the exits all the B exits are empty
  	// C exits or the middle exits are occupied by people
  	//int h_exit[6] = {1,1,1,1,1,1};
  	//exit is 1 for those wxits which are open and 0 for those which are close
  	//block A[],block B[4][55],block C[4][55],Passenger P[] ,int seat[][100],int numPass
  	//cudaMalloc((void **) &array1_d , WIDTH*WIDTH*sizeof (int) ) ;
  	// Here the game starts
  	//Emergency! Emergency! Emergency! Run all of you Out of the plane
    printf("Enter 1 if the exit is open and 0 if the exit is close for all the 8 exits");
    int h_exit[8];
    int *d_exit;
    for(i=0;i<8;++i)
      scanf("%d",&h_exit[i]);

  	//__global__ void movement_to_exit(block A[],block B[4][55],block C[4][55],Passenger P[] ,int seat[][100],int numPass) //runs for each Passenger and make his movmenent according to the positions
  	int numout=0,numprev=0;
  	j=0;
    cudaMalloc((void **) &P , numPass*sizeof (Passenger) ) ;
    cudaMalloc((void **) &B , (55*4)*sizeof (block) ) ;
    cudaMalloc((void **) &C , (55*4)*sizeof (block) ) ;
    cudaMalloc((void **) &A , 1040*sizeof (block) ) ;
    cudaMalloc((void **) &seat , (100*100)*sizeof (int) ) ;
    cudaMalloc((void **) &d_exit , (8)*sizeof (int) ) ;

    // select exit
    map_Passenger_to_exit(h_P,h_seat, h_C,h_B,h_exit);
   /* for(j=0;j<4;++j)
    {
      for(i=0;i<55;++i)
      {
       printf("%d",h_C[j][i]);
      }
      printf("\n");
    }*/
    count1=0;
int filecounter = 0;  	
while(numout<numPass)
  	 {
++filecounter;
     // ifiiii(j==1000)
      //  break;
      numprev=numout;
  		numout=0;

   /* for(i=0;i<30;++i)
    {
      for(j=0;j<10;++j)
        printf("%d ",h_seat[i][j]+1);
      printf("\n");
    }
    */

/*    for(i=0;i<numPass;++i)
      {
        if(P[i].status!=4)
        printf("Passengr %d : (%d,%d) : %d : ans : %d : dir : %d\n",i,h_P[i].x,h_P[i].y,h_P[i].status,h_P[i].ans,h_P[i].dir);
      }

  */
    //printf("Passengr %d : (%d,%d) : %d : ans : %d : dir : %d\n",3,h_P[3].x,h_P[3].y,h_P[3].status,h_P[3].ans,h_P[3].dir);

    cudaMemcpy ( P , h_P , numPass*sizeof (Passenger) , cudaMemcpyHostToDevice);
    cudaMemcpy ( seat , h_seat , 100*100*sizeof (int) , cudaMemcpyHostToDevice);
    cudaMemcpy ( C , h_C , 4*55*sizeof (block) , cudaMemcpyHostToDevice);
    cudaMemcpy ( B , h_B , 4*55*sizeof (block) , cudaMemcpyHostToDevice);
    cudaMemcpy ( A , h_A , 1040*sizeof (block) , cudaMemcpyHostToDevice);
    cudaMemcpy ( d_exit , h_exit , 8*sizeof (int) , cudaMemcpyHostToDevice);


      movement_to_exit<<< 1,numPass >>>(A,B,C,P,seat,d_exit,numPass);

  		cudaError_t err1 = cudaPeekAtLastError();
      cudaDeviceSynchronize();
      //printf( "Got CUDA error ... %s \n", cudaGetErrorString(err1));

    cudaMemcpy ( h_P , P , numPass*sizeof (Passenger) , cudaMemcpyDeviceToHost);
    cudaMemcpy ( h_seat , seat , 100*100*sizeof (int) , cudaMemcpyDeviceToHost);
    cudaMemcpy ( h_C , C , 4*55*sizeof (block) , cudaMemcpyDeviceToHost);
    cudaMemcpy ( h_B , B , 4*55*sizeof (block) , cudaMemcpyDeviceToHost);
    cudaMemcpy ( h_A , A , 1040*sizeof (block) , cudaMemcpyDeviceToHost);


// creating file
  // FILE *fp = NULL;

    char filename[50] = "res";
    char str[20];
    sprintf(str, "%03d", filecounter);
//	printf("filecounter checkup %s",str);    
	strcat(filename,str);
    strcat(filename,".res");
float tt = (j*40.6) + 7000.0;
createGlobalMatrix(h_seat, h_A, h_B, h_C, filename,tt);
/*
FILE *fp = NULL;
    fp = fopen(filename, "w");
        fprintf(fp," -----------------------------\n"); 
        fprintf(fp, "\n");
	fprintf(fp, "%f", j*40);
        fprintf(fp,"\n ----------------------------- \n"); 
        fprintf(fp,"passenger \n"); 
        fprintf(fp,"\t \t 1000 \t  1 \n"); 
	for (int d = 0; d < 1000; ++d)
      {
	if(h_A[d].passid == -1)
	{
		fprintf(fp, "0");
       		fprintf(fp, "\n");
	}
	else{
		fprintf(fp,"1");
		fprintf(fp, "\n");
        }
}
fprintf(fp,"\n ----------------------------- \n");
    fclose(fp);
*/

    //printToFile(filename,h_A);
//file creation complete

  		for(i=0;i<numPass;i++)
  		{
  			if(h_P[i].status == 4)
  				numout++;
  		 //printf("%d\n",h_P[i].status);
      }

    if(numprev==numout)
      {
        printf("*");
        count1++;
      }
    else
    {
      count1=0;
      printf("%d %d\n",numout,j);
    }
      if(numout==numPass)
        break;

    //printf("%d %d\n",numout,j);

     /* if(count1>100)
      {
        for(i=0;i<numPass;i++)
        {
          if(h_P[i].status!=4)
          {
                printf("Passenger %d : (%d,%d) : %d : ans : %d : dir : %d\n",i,h_P[i].x,h_P[i].y,h_P[i].status,h_P[i].ans,h_P[i].dir);
          }
        }
        break;
      }
*/
     // printf("%d\t %d\n",numout,j);
  		j++;
    
   // printf("jjjj : %d\n", j);
  	}

  	float timeSteps = 40.6;
	printf("%f\n",j);
  	printf("total time:  %f\n",j*timeSteps + 7000.0);
  //  printf("%f\n",j*timeSteps);
   // printf("timeSteps : %f\n",j);
    printf("filecounter : %d\n", filecounter);
  	return 0;
  }


  int random(int min,int max);

  void pass_input(Passenger *P,int n)
  {
    int i;//r;
    srand(time(0));
    Passenger *tp=P;

    for(i=0;i<n;++i,tp++)
      {
        //r=rand();
        //  printf("%d\n",r);
        tp->id=i;
        //  tp->x=
        //
        tp->sex=random(0,1); // Male or female(random 0-1)
        tp->status = 0;
        tp->Mtime=tp->sex?random(1000,1750):random(1100,1950);
        tp->Wtime=50;
        tp->Rtime=random(400,700); // Random  (500-1000)ms
        tp->fear=-1; //fear value 0
        tp->agility=-1; // agility value

        tp->diameter=7;  //random(8,10);//(Random ) // diameter occupied by passenger
        tp->totaltime=0; //total time to evacuate
        tp->totalDist=0; //total distance to exit
        
	if(tp->sex==0)
         tp->speed=1.5f;  //Random (1-1.5 ) speed of passenger
        else
          tp->speed=1.0f;

        tp->grpstatus=-1; // Not in this paper in group or not
        tp->timeSteps=178; // minimum unit of time = 178 miliseconds
        tp->res=0;
        printf("id : %d , sex : %d , Mtime : %d, Rtime : %d\n",tp->id,tp->sex,tp->Mtime,tp->Rtime);
      }

  }


Aircraft aircraftInput(char name[]){
Aircraft A;   
 char filename1[100];
strcpy(filename1,name);    
strcat(filename1,".dat");

   FILE *fp;
   char buff[255];
   int res[10];
   int k =0;
   fp = fopen(filename1, "r");
   while(fgets(buff, 80, fp) != NULL)
   {
   //fscanf(fp, "%s", buff);
   //printf("%s\n", buff );
   int result = atoi(buff);
   //printf("%d\n", result);
    res[k] = result;
    ++k;

    }
    fclose(fp);
   /*for(int u =0;u<4;++u){
	printf(" \n %d",res[u]);  
 }*/
   A.row = res[0];
   A.column = res[1];
   A.numOfExitPassage = res[2];
   A.maxNumPassenger = res[3];
   return A;
}

void createGlobalMatrix(int h_seat[100][100], block h_A[1040], block h_B[4][55], block h_C[4][55], char filename[50],float tt){
int global[1040][130];
//printf("\n 1. we reached here\n");
//printf("%s","testing");
    //main exit 1
    int k =0, i=0;
//printf("\n1.  i= %d",i);
    for(k =0;k<50;++k){
      for (i = 0; i < 55; ++i)
      {
          if(h_B[0][i].passid==-1){
            global[k][i] = 0;
          }
          else{
            global[k][i] = 1;
          }
        }
       // int temp = i;
        if(h_A[k].passid == -1){
            global[k][i] = 0;
          }
          else{
            global[k][i] = 1;
          }
	int temp = i;
      for (i = 54; i >=0; --i)
      {
          if(h_B[1][i].passid == -1){
            global[k][temp] = 0;
          }
          else{
            global[k][temp] = 1;
          }
        ++temp;
	}
      }
//printf("\n2. i= %d",i);
      // 1-14 seats
//printf("\n 3. we reached here\n");      
int p = 0;
      for (i = 50; i < (14*30)+50; ++i)
      {
          int u=0;
        for (int j = 0; j < 3; ++j)
        {
          if (h_seat[p][j] == -1)
          {
            for (; u < 18*(j+1); ++u)
            {
              global[i][u] = 0;
            }
          }
          else{
              for (; u < 18*(j+1); ++u)
              {
                global[i][u] = 1;
              }
          }
        }
        
	for(int po =0;po<18;++po){
		if(h_A[i].passid == -1)
			global[i][u] = 0;
        	else
			global[i][u] = 1;
		++u;
	}
        u=0;
        for (int j = 3; j < 6; ++j)
        {

          if (h_seat[p][j] == -1)
          {
            for (; u < 18*(j+1); ++u)
            {
              global[i][u] = 0;
            }
          }
          else{
              for (; u < 18*(j+1); ++u)
              {
                global[i][u] = 1;
              }
          }
        }
        if ((i+1-50)%30 == 0)
        {
          ++p;
        }
      }
//printf("\n3. i= %d",i);

      //middle exits
//printf("\n 4. we reached here\n");
      for(k =i;k<i+50;++k){
      int j =0;
      for (j = 0; j < 55; ++j)
      {
          if(h_C[0][j].passid == -1){
            global[k][j] = 0;
          }
          else{
            global[k][j] = 1;
          }
        }
	for(int po =0;po<18;++po){
                if(h_A[i].passid == -1)
                        global[i][j] = 0;
                else
                        global[i][j] = 1;
                ++j;
        }
        int temp = j;
        

      for (j = 54; j >=0; --j)
      {
          if(h_C[1][j].passid == -1){
            global[k][temp] = 0;
          }
          else{
            global[k][temp] = 1;
          }
         ++temp;
	}
      }

      // middle exits  correct the second loop for j.. j is not in the sync
//printf("\n4. i= %d k = %d",i,k);
      for(;k<i+100;++k){
      int j=0;
      for (j = 0; j < 55; ++j)
      {
          if(h_C[2][j].passid == -1){
            global[k][j] = 0;
          }
          else{
            global[k][j] = 1;
          }
        }
        
        for(int po =0;po<18;++po){
                if(h_A[i].passid == -1)
                        global[i][j] = 0;
                else
                        global[i][j] = 1;
                ++j;
        }
        int temp = j;

      for (j = 54; j >=0; --j)
      {
          if(h_C[3][j].passid == -1){
            global[k][temp] = 0;
          }
          else{
            global[k][temp] = 1;
          }
        }
      }

//printf("\n 5. we reached here\n");
      // 17 - 30 seats
//printf("\n5. i= %d",i);
      for (i = k; i < (28*30)+150; ++i)
      {
          int u=0;
        for (int j = 0; j < 3; ++j)
        {
          if (h_seat[p][j] == -1)
          {
            for (; u < 18*(j+1); ++u)
            {
              global[i][u] = 0;
            }
          }
          else{
              for (; u < 18*(j+1); ++u)
              {
                global[i][u] = 1;
              }
          }
        }
        for(int po =0;po<18;++po){
                if(h_A[i].passid == -1)
                        global[i][u] = 0;
                else
                        global[i][u] = 1;
                ++u;
        }
        //int temp = u;
        //u=0;
        for (int j = 3; j < 6; ++j)
        {

          if (h_seat[p][j] == -1)
//        fprintf(fp, "\n");
          {
            for (; u < 18*(j+2); ++u)
            {
              global[i][u] = 0;
            }
          }
          else{
              for (; u < 18*(j+2); ++u)
              {
                global[i][u] = 1;
              }
          }
        }
        if ((i+1-150)%30 == 0)
        {
          ++p;
        }
      }
//printf("%d",i);
//printf("\n 6. we reached here\n");

//end exits

//printf("%d",i);
k =i;      
//int q = k+50;
     
	for(int ty = 0;ty<50;++ty){
     // int i =0;
      for (i = 0; i < 55; ++i)
      {
//	printf("\n1111");
//printf("value of %d",i);	          
	if(h_B[2][i].passid == -1){
            global[k][i] = 0;
          }
          else{
            global[k][i] = 1;
          }
        }
//	printf("\n2");

        
	for(int po =0;po<18;++po){
                if(h_A[k].passid == -1)
                        global[k][i] = 0;
                else
                        global[k][i] = 1;
                ++i;
        }
        int temp = i;


//	printf("\n3");

      for (i = 54; i >=0; --i)
      {
  //      printf("\n4");
  
	if(h_B[3][i].passid == -1){
            global[k][temp] = 0;
          }
          else{
            global[k][temp] = 1;
          }
	++temp;
        }
++k;
//	printf("\n5");
//	printf("\n k = %d",k);
      }
//printf("\n 2. we reached here\n");
FILE *fp = NULL;
    fp = fopen(filename, "w");
        //fprintf(fp," -----------------------------\n");
        //fprintf(fp, "\n");
        //fprintf(fp, "   %f", tt);
        //fprintf(fp,"\n -----------------------------\n");
        //fprintf(fp," passenger evacuation\n");
        //fprintf(fp,"         130          1040\n");
        for (int d = 0; d < 1040; ++d)
        {
        for(int g = 0; g < 130; ++g){
                fprintf(fp, "%d,", global[d][g]);
	}
	fprintf(fp,"\n");
	}
//fprintf(fp," -----------------------------\n");
    fclose(fp);

}

  int random(int min,int max)
  {
    int r = rand();
    r=r%(max-min+1);
    r=r+min;
    return r;
  }
  void printToFile(char filename[], int a[]){

  FILE *fp = NULL;
    fp = fopen(filename, "w");
      for (int j = 0; j < 1040; ++j)
      {
        fprintf(fp, "%d", a[j]);
	fprintf(fp, "\n");      
	}

    fclose(fp);

  }

