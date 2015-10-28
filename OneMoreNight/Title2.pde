
Option[] options;

class Option {
  String text;
  int setState;

  Option (String inText, int inState) {
    text = inText;
    setState = inState;
  }

  void choose() {
    state = setState;
  }
}
class TitleZombie {
  float x, y;
  PVector vel;
  PImage curPic;
  //int frame; // for animation

  TitleZombie (float xpos, float ypos) {
    //frame = 0;
    x = xpos;
    y = ypos;
    curPic = zLeft;
    vel = new PVector(0, 0);
  }

  void update(PVector target) {
    if (random(1) < 0.05) { // 5% chance to update target
      this.vel.x = target.x-this.x;
      this.vel.y = target.y-this.y;
      this.vel.normalize();
      if (this.vel.x < 0) {
        this.curPic = zLeft; //[this.frame];
      } else if (this.vel.x > 0) {
        this.curPic = zRight; //[this.frame];
      }
    }
    /*    For use with multiple frames
     if (this.vel.x < 0) {
     this.curPic = zLeft; //[this.frame];
     } else if (this.vel.x > 0) {
     this.curPic = zRight; //[this.frame];
     }
     if (random(1) < .7) {
     this.frame = (this.frame+1) % zRight.length;
     }
     */

    this.x += this.vel.x;
    this.y += this.vel.y;
  }
}

class Drop {
  float x, y;
  final color col = (#0F80F5); //color(155, 47, 47); //(#0F80F5);
  boolean inFront;
  Drop() {
    x = random(width);
    y = random(-height, grass);
    inFront = bool(str(round(random(1))));
  }

  void update() 
  { 
    this.y += 3;
    if (this.y > grass) 
    {
      this.y = random(-1 * height, 0);
      this.x = random(width);
    }
  }
}

boolean moveBlood = true;

//Images
PImage bloodTop;
PImage zLeft;
PImage zRight;
PImage survivor;
PImage[] campfire = new PImage [6];

//Vectors
PVector target;

//Fonts
PFont titleScreenFont;
PFont creditFont;

//Integers
int grass;
int bloodx;
int bloody;
int textYPos;
int opacity = 0;
int survX;

//Floats
float fireFrame = 0;

//Objects
TitleZombie[] titleHorde = new TitleZombie[15];
Drop[] rain = new Drop[500];

