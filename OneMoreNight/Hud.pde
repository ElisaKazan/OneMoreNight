
String words1 = "";
String words2 = ""; 
String words3 = "";
String words4 = "";

PImage overlay;

int areaFade = 500;

void drawConsole()
{
  int x = 15;
  int y = 570;

  textFont(plain);
  fill(#C6B698);
  textAlign(LEFT, TOP);
  textSize(15);
  text(words1, x, y + 54);   // First
  text(words2, x, y + 36);   // Second
  text(words3, x, y + 18);   // Third
  text(words4, x, y);        // Forth
}

void console(String newWords)
{
  words4 = words3;
  words3 = words2;
  words2 = words1;
  words1 = newWords;
}

void pauseScreen() {
  pushMatrix();
  fill(#000000, 150);
  rect(0, 0, width, height);
  fill(#FFFFFF);
  textFont(plain);
  textSize(26);
  textAlign(CENTER, CENTER);
  text("Paused", width/2 - 50, height/2);
  popMatrix();
}

void drawHud() {

  if (!day) { 
    //imageMode(CENTER);
    //image(overlay, you.pos.x+int(TRANS.x), you.pos.y+int(TRANS.y));
    // println(frameRate);

    //tilesAcross = ceil((width/tSize/2)/3);
    //tilesDown = ceil((height/tSize/2)+1)/3;

    fill(0, 0, 0, 100);
    rect(0, 0, width, height);
    if (current.ID == 0)
    { 
      rect(0, 0, width, height);
    }
  } //else {
  //tilesAcross = ceil(width/tSize/2);
  //tilesDown = ceil(height/tSize/2)+1;
  // }
  //*/

  //Hud coordinates
  final int hudX = 671;
  final int hudY = 4;
  final int hudW = 125;
  final int hudH = 642;

  //Colours
  final color light = color(#766A54);
  final color dark = color(#554932);
  final color grey = color(#C6B698);
  final color red = color(#CE283B);
  final color yellow = color(#E8D528);
  final color green = color(#20B22B);

  //Day
  final int dayX = hudX + 5;
  final int dayY = hudY + 5;
  final int dayW = hudW - 10;
  final int dayH = dayW;

  //Clock
  final int clockX = dayX;
  final int clockY = dayY + dayH + 5;
  final int clockW = dayW;
  final int clockH = 55;

  //Bars
  final int x1 = clockX;
  final int y1 = clockY + clockH + 25;
  final int x2 = x1;
  final int y2 = y1 + 40;
  final int x3 = x2;
  final int y3 = y2 + 40;
  final int barW = 115;
  final int barH = 15; 

  //Draw
  pushMatrix();
  resetMatrix();
  pushStyle();  
  rectMode(CORNER);
  textFont(plain, 20);

  //Draws the box
  fill(light);
  stroke(dark);
  strokeWeight(4);
  rect(hudX, hudY, hudW, hudH);

  //Day 
  fill(dark);
  noStroke();
  rect(dayX, dayY, dayW, dayH);
  pushStyle();
  fill(grey);
  textFont(dayFont, 40);
  textAlign(CENTER, TOP);
  text("Day", dayX + dayW/2, dayY + 25);
  text(nf(timeDay, 2), dayX + dayW/2, dayY + 65); //actual number changing
  popStyle();

  //Clock (Timer)
  fill(dark);
  noStroke();
  rect(clockX, clockY, clockW, clockH);
  pushStyle();
  fill(grey);
  textFont(clock, 48);
  textAlign(CENTER, CENTER);

  //Fixing the time
  if (countdown > 60000)
  {
    timeMinutes = (int) countdown/60000;
    timeSeconds = (int) countdown%60000;
  } else
  {
    timeMinutes = 0;
    timeSeconds = (int) countdown;
  }

  text(nf(timeMinutes, 2) + ":" + nf(timeSeconds / 1000, 2), clockX + clockW/2, clockY + clockH/2);
  popStyle();

  //Health, Hunger and Morale Bars
  noStroke();
  //Back of bar
  fill(dark); 
  rect(x1, y1, barW, barH); //health
  rect(x2, y2, barW, barH); //hunger
  rect(x3, y3, barW, barH); //morale

  //Actual Bars
  //Health
  if (you.health < 20)
  {
    fill(red);
  } else if (you.health < 75)
  {
    fill(yellow);
  } else
  {
    fill(green);
  }
  rect(x1, y1, barW * you.health/100, barH); 

  //Hunger
  if (you.hunger < 20)
  {
    fill(red);
  } else if (you.hunger < 75)
  {
    fill(yellow);
  } else
  {
    fill(green);
  }
  rect(x2, y2, barW * you.hunger/100, barH); 

  //Morale
  if (you.morale < 20)
  {
    fill(red);
  } else if (you.morale < 75)
  {
    fill(yellow);
  } else
  {
    fill(green);
  }
  rect(x3, y3, barW * you.morale/100, barH); 

  //Text
  fill(grey);
  textSize(15);
  textAlign(LEFT, TOP);
  text("Health : " + (int)you.health + "%", x1, y1 + barH + 3);
  text("Hunger : " + (int)you.hunger + "%", x2, y2 + barH + 3);
  text("Morale : " + (int)you.morale + "%", x3, y3 + barH + 3);    

  //Weapon
  fill(dark);
  rect(x3, y3 + 50, dayW, dayH);
  Item temp;
  if (you.equippedWeapon != -1) {
    temp = items.get(you.equippedWeapon);
    imageMode(CENTER);
    image(temp.pic, x3+dayW/2, (y3 + 50)+dayH/2);
    textAlign(CENTER, TOP);
    text(temp.name, x3 + 8 + BOXW/2, y3 + 55 + dayH);
  } else {
    textAlign(CENTER, TOP);
    text("Fists", x3 + 8 + BOXW/2, y3 + 55 + dayH);
  }

  if (you.cooldown != 0) {
    fill(dark, 200);
    rect(x3, y3 + 50, dayW, dayH);
  }

  //Controls
  textSize(15);
  fill(dark);
  textAlign(CENTER, TOP);
  text("Interact (f)", hudX + hudW/2, hudY + hudH - 80);
  text("Inventory (i)", hudX + hudW/2, hudY + hudH - 60);
  text("Journal (j)", hudX + hudW/2, hudY + hudH - 40);
  if (current.ID != 0) text("Building (b)", hudX + hudW/2, hudY + hudH - 20);


  if (areaFade > 0) areaFade-=2;
  fill(light, areaFade);
  textSize(25);
  textAlign(LEFT, TOP);
  text(current.name, 5, 5);

  //Text Box on the bottom
  final int messageX = 10;
  final int messageY = 560;
  final int messageW = 650;
  final int messageH = 85;
  fill(grey, 100); //Change to black with white text
  rectMode(CORNER);
  rect(messageX, messageY, messageW, messageH);  
  drawConsole();
  popStyle();

  if (invShown) showInventory();
  if (journalShown) journal.display();
  if (buildingOverviewShown && current.ID != 0) current.showOverview();

  if (crafting && selectedItems.size() != 0) {
    fill(grey, 200);
    rect(mouseX+10, mouseY+10, 200, 25);
    fill(dark, 200);
    textAlign(LEFT, TOP);
    textSize(16);
    if (currCraft == null) {
      text("Crafts: nothing", mouseX+15, mouseY + 15);
    } else {
      Item tempItem = items.get(currCraft.result);
      text("Crafts: " + tempItem.name, mouseX+15, mouseY+15);
    }
  }
  popMatrix();
}

