#include<stdio.h>
#include"Passenger.h"
#include"Aircraft.h"

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
      tp->Mtime=tp->sex?random(875,1750):random(920,1950);
      tp->Wtime=50;
      tp->Rtime=random(400,700); // Random  (500-1000)ms
      tp->fear=-1; //fear value 0
      tp->agility=-1; // agility value
      tp->diameter=-1;//(Random ) // diameter occupied by passenger
      tp->totaltime=0; //total time to evacuate
      tp->totalDist=0; //total distance to exit
      tp->speed=0;  //Random (1-1.5 ) speed of passenger
      tp->grpstatus=-1; // Not in this paper in group or not
      tp->timeSteps=178; // minimum unit of time = 178 miliseconds
      printf("id : %d , sex : %d , Mtime : %d, Rtime : %d\n",tp->id,tp->sex,tp->Mtime,tp->Rtime);
    }
  
}
int random(int min,int max)
{
  int r = rand();
  r=r%(max-min+1);
  r=r+min;
  return r;
}
