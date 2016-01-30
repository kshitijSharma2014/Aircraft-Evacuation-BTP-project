#include"Passenger.h"
#include"Aircraft.h"

Aircraft* input()
{
  Aircraft* air = (Aircraft*)malloc(sizeof(Aircraft));
  char s[100];
  int row;
  scanf("%d",&row);
  scanf("%s",s);
  int i=0;
  air->x=s[i]-'0';
  i+=2;
  air->y=s[i]-'0';
  i++;
  if(s[i]=='\0')
    air->z=-1;
  else
    air->z=s[i+1]-'0';

  scanf("%d",&air->maxNumPassenger);
  scanf("%lf",&air->aisleWidth);
  scanf("%lf",&air->mainExitWidth);
  scanf("%lf",&air->emExitWidth);
  return air;
}