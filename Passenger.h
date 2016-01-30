	typedef struct Passenger{
	int id; //person id
	int x; //x coordinaate this represent the row
	int y; //y coordinate this represent the column 1-6 or the
	int place ; //1 in seats 2 in exit paths
	int exit ; //exit moving towards
	// 1-6
	int res;
	int status; // 0 : is his seat aisle
				// 1 : is in aisle
	 			// 2 : in the exit aisle
	 			// 3 : in the midle exit ailse
				// 4 : out of the plane
	//int N;
	int Mtime; //movement time
	int Wtime; //wait time
	int Rtime; //reaction time
	float fear; //fear value
	float agility; // agility value
	int diameter; // diameter occupied by passenger
	float totaltime; //total time to evacuate
	float totalDist; //total distance to exit
  float speed; // speed of passenger
	char sex; // Male or female
	int grpstatus; // in group or not
	int ans;
	int dir;
	double timeSteps; // minimum unit of time = 178 miliseconds
} Passenger;
