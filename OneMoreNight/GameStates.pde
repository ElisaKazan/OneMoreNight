
final int TITLE = 0;
final int PLAY = -1;
final int DEAD = -2;
final int CREDITS = -3;
final int QUIT = -4;
final int PAUSE = -5;
final int CONTROLS = -6;
final int CUSTOMIZE = -7;

int state = TITLE;

PVector TRANS;

String deathReason = "";

void titleScreenChange() {
  int optionsX = width/2;
  int optionsY = height/2;
  int optionsH = 25;
  int dim = 100;

  currChoice = constrain((mouseY-optionsY)/optionsH, 0, options.length-1);

  background(0);
  fill(#FFFFFF);
  textFont(plain);
  textSize(30);
  textAlign(CENTER, BOTTOM);
  text("One More Night", width/2, height/2 - 100);

  titleScreen();

  textSize(18);
  textAlign(CENTER, TOP);
  for (int i=0; i<options.length; i++) {
    fill(#FFFFFF);
    if (i!=currChoice) fill(#FFFFFF, dim);
    text(options[i].text, optionsX, optionsY + optionsH*i);
  }
}

void customize() {
  pushStyle();
  background(0);
  fill(#FFFFFF);
  textFont(plain);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Enter your name\n" + you.name, width/2, height/2);
  popStyle();
}

void instructions() {
  background(0); 
  fill(255);
  pushStyle();
  textSize(30);
  text("Controls", width/2, height/8);
  image(controls, width*5/9 - 20, height/3 + 50);
  fireFrame = (fireFrame + 0.2) % campfire.length;
  image(survivor, 125, height/2);
  image(campfire[int(fireFrame)], 175 + campfire[int(fireFrame)].width/2 + 10, height/2 + survivor.height/2 - campfire[int(fireFrame)].height/2 + 4);
  popStyle();
}

void play() {
  if (day) timer(); 

  you.hunger = max(you.hunger - (50.0/float(dayLength)) * deltaTime, 0);

  if (you.hunger <= 0) {
    you.health = max(you.health - (50.0/float(dayLength)) * deltaTime, 0);
  }

  if (you.health <= 0) {
    state = DEAD;
    if (you.hunger <= 0) {
      deathReason = "You starved to death.";
    } else {
      deathReason = "You were eaten by zombies.";
    }
  }

  if (song != null && !song.isPlaying()) {
    song = null;
    theme.play();
  }

  background(0); 
  TRANS.set(width/2-50-you.pos.x, height/2-you.pos.y); 
  current.showMap(); 

  imageMode(CENTER); 

  if (you.flashTimer > 0) {
    you.showMuzzleFlash();
  }

  pushMatrix(); 
  translate(width/2-50-you.pos.x, height/2-you.pos.y); 

  //image(tempBKG, 0, 0);
  you.display(); 
  pushStyle(); 
  noFill(); 
  stroke(#FFFFFF); 
  int range = you.baseRange; 
  if (you.equippedWeapon != -1) {
    Item weapon = items.get(you.equippedWeapon); 
    range = weapon.range;
  }
  ellipse(you.pos.x, you.pos.y, range*2, range*2); 

  popStyle(); 
  Person tempZ; 
  for (int i=0; i<current.zombies.size (); i++) {
    tempZ = current.zombies.get(i); 
    if (tempZ.whichBuilding == current.ID && dist(tempZ.pos.x, tempZ.pos.y, you.pos.x, you.pos.y) < updateRadius) {
      tempZ.display(); 
      if (state == PLAY) tempZ.update();
    }
  }

  popMatrix(); 

  if (state == PLAY) you.update(); 

  drawHud();

  if (goToSleep) {
    if (screenFade < 255) {
      fill(#000000, screenFade);
      rect(0, 0, width, height);
      screenFade += 2.5;
      pauseTime = 5000;
    } else {    // if it's done fading out
      fill(#000000);
      rect(0, 0, width, height);
      buildingOverviewShown = false;
      if (pauseTime > 0) {
        theme.pause();
        pauseTime -= deltaTime;
        // play random sounds
        AudioPlayer sound = zombieMoans[int(random(zombieMoans.length))];
        if (!sound.isPlaying()) {
          sound.rewind();
          sound.setGain(0);
          sound.play();
        } else {
          sound = zombieGrowls[int(random(zombieGrowls.length))];
          if (!sound.isPlaying()) {
            sound.rewind();
            sound.setGain(0);
            sound.play();
          } else {
            sound = nightBanging[int(random(nightBanging.length))];
            if (!sound.isPlaying()) {
              sound.rewind();
              sound.setGain(0);
              sound.play();
            }
          }
        }
      } else {
        for (AudioPlayer sound : nightBanging) sound.pause();
        for (AudioPlayer sound : zombieMoans) sound.pause();
        for (AudioPlayer sound : zombieGrowls) sound.pause();

        if (song == null)  theme.play(); // if no song was playing

        goToSleep = false;
        sleep(timeDay+1);
        wakeUp = true;
        day = true;
        countdown = dayLength;
        timeDay++;
      }
    }
  } else if (wakeUp) {
    if (screenFade > 0) {
      fill(#000000, screenFade);
      rect(0, 0, width, height);
      screenFade -= 2.5;
    } else {    // if it's done fading out
      wakeUp = false;
    }
  }
}

void pause() {
  play();   // since it's just an overlay
  pauseScreen();
}

void dead() {
  background(0); 
  textFont(plain); 
  textAlign(CENTER, BOTTOM); 
  fill(255); 
  image(gameover, width/2, 150);
  text(deathReason + "\nYou have fallen after " + timeDay + " days.\n\nClick anywhere to continue", width/2, height*3/5); 

  //Grass
  fill(#486A25); //green
  rectMode(CORNER); 
  noStroke(); 
  rect(0, grass - 5, width, height * 1/6); 

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

  /*
      TO DO:
   Have zombies walk on the ground
   Have zombies surround a bleeding corpse
   Play again?
   */
}

