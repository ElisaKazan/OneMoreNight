
final int dayLength = 600 * 1000;//75 * 1000; //first number is the actual number of seconds
boolean day = true;
int time;
float countdown;
int deltaTime;
boolean nightWarning = true;

boolean addDay = false;
int timeDay = 0;
int timeMinutes = 0;
int timeSeconds = 0;

void timer()
{  

  //  println(countdown);

  if (countdown <= 0) {    // day is over
    if (nightWarning && current.ID != 0) { 
      console("\"I should really get inside... it's getting dark out.\"");
      nightWarning = false;
    }
    day = false;
    for (Person zombie : buildings.get (0).zombies) {
      zombie.transform();
    }
  }
}

