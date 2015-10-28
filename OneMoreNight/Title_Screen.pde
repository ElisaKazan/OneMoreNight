

//Booleans
boolean mainScreen = true;
boolean creditScreen = false;

PImage house;
PImage steak;



//Credits
String [] credits;

//Music
Minim minim;
AudioPlayer soundtrack;



void setupTitle() {
  size(800, 650);
  background(0);
  textYPos = height;

  //Music and Images
  loadTitleImages();
  loadTitleMisc();
  //  soundtrack.play();

  //Integers
  grass = height - 80;
  bloodx = 0;
  bloody = 0 - bloodTop.height;
  textYPos = height;

  //Vector
  target = new PVector (0, 0);

  for (int z = 0; z < titleHorde.length; z++) {
    titleHorde[z] = new TitleZombie(random(width), grass - zLeft.height/2);
  }

  for (int d = 0; d < rain.length; d++) {
    rain[d] = new Drop();
  }
}

void loadTitleImages() 
{
  bloodTop = loadImage("TitleScreen/BloodTop.png");
  zLeft = loadImage("TitleScreen/Zleft.png");
  zRight = loadImage("TitleScreen/Zright.png");
  survivor = loadImage("TitleScreen/survivor at fire.png");
  for (int i=0; i<campfire.length; i++) 
  {
    campfire[i] = loadImage("TitleScreen/campfire/frame_00" + i + ".png");
  }
  house = loadImage("TitleScreen/myHouse.png");
  steak = loadImage("TitleScreen/steak.png");
} 

void loadTitleMisc() {
  titleScreenFont = loadFont("TitleScreen/FaceYourFears-60.vlw"); 
  creditFont = loadFont("TitleScreen/Chiller-Regular-48.vlw");
  credits = loadStrings("credits.txt");
  minim = new Minim(this);
  soundtrack = minim.loadFile("TitleScreen/Not Ready To Die.mp3");
}

void titleScreen() {
  //noCursor();
  pushStyle();
  noStroke();
  background(0); //55, 57, 54);

  //Hills and House
  imageMode(CORNER);
  fill(21, 57, 21); //darkest green
  ellipseMode(CENTER);
  ellipse(width, height, width * 2, height * 2/3);  //Far hill
  fill(27, 75, 27); //dark green
  ellipse(0, height, width * 2, height/2); //Close Hill
  image(house, width/2 + 270, height/2 + 50);

  //Rain
  rectMode(CENTER);
  noStroke();
  fill(rain[0].col);
  for (int d = 0; d < rain.length; d++) {
    rain[d].update();
    if (!rain[d].inFront) rect(rain[d].x, rain[d].y, 2, 4);
  }

  //Blood on bottom
  imageMode(CORNER);
  image(bloodTop, bloodx, bloody);

  image(title, 15, 0);

  for (Drop d : rain) {
    if (d.inFront) rect(d.x, d.y, 2, 4);
  }

  //Grass
  noStroke();
  rectMode(CORNER);
  fill(70, 118, 44);
  rect(0, grass, width, height);

  if (bloody >= 0) {
    moveBlood = false;

    //Title shows up
    /*
    pushStyle();
     
     textFont(titleScreenFont, 75);
     textAlign(CENTER, CENTER);
     fill(0, 0, 0, opacity);
     opacity++;
     text("One More Night", width/2, 100);
     
     popStyle();
     */
  }
  /*
  //Move blood
   if (moveBlood)
   {
   bloody ++;
   }
   */

  //Zombies following mouse
  target.x = mouseX;
  target.y = grass - titleHorde[0].curPic.height/2;
  for (int z=0; z<titleHorde.length; z++) {
    titleHorde[z].update(target);
  }

  imageMode(CENTER);
  for (int z = 0; z < titleHorde.length; z++) {
    image(titleHorde[z].curPic, titleHorde[z].x, titleHorde[z].y);
  }

  //image(steak, mouseX, mouseY);
  popStyle();
}

void creditScreen() {
  pushStyle();
  background(0); //55, 57, 54);
  textAlign(TOP, CENTER);
  textFont(plain, 15);
  fill(#FFFFFF);

  textYPos -= 1;
  for (int l = 0; l < credits.length; l++) {
    text(credits[l], width/3, textYPos + 35*l);
  }

  survX = 50;

  imageMode(CENTER);
  image(survivor, survX, height/2);

  fireFrame = (fireFrame + 0.2) % campfire.length;
  image(campfire[int(fireFrame)], survX + survivor.width/2 + campfire[int(fireFrame)].width/2 + 10, height/2 + survivor.height/2 - campfire[int(fireFrame)].height/2 + 4);
  popStyle();
}

