/*
  Stats:
 - Zombies Killed ✓
 - >> melee vs ranged?
 - >> reinforcments used
 
 - Possibly on death, turn into journal page to be found by player another round
 
 */

String[] storyline;
String[] loreNames;

Journal journal;
boolean journalShown = false;

Item lore;

// stats
int zombiesKilled = 0;
int itemsFound = 0;
int itemsCrafted = 0;
int itemsUsed = 0;
int shotsFired = 0;
int buildingsEntered = 0;
int buildingsCleared = 0;
int pixelsTravelled = 0;
Item favWeapon;

class Journal {
  StringList pages;
  int currPage;

  final int LX = INVX + 75;
  final int LY = INVY;
  final int LW = int(INVW*0.75);
  final int LH = INVH;
  final int border = 25; 

  Journal() {
    pages = new StringList();
    currPage = 0;
  }

  int getSize() { 
    return pages.size();
  }

  void addPage(String newPage) {
    pages.append(newPage);
  }

  void nextPage() {
    currPage++;
    if (currPage >= pages.size()) {
      currPage--;
    } else {
      nextPageSound.rewind();
      nextPageSound.play();
    }
  }

  void prevPage() {
    currPage--;
    if (currPage < 0) {
      currPage++;
    } else {
      prevPageSound.rewind();
      prevPageSound.play();
    }
  }
  void showPage() {
    String entry = "";
    if (currPage == 0) {      // stats page
      entry = showStatPage();
    } else {
      entry = pages.get(currPage);
    }
    pushStyle();
    fill(#000000);
    textFont(plain);
    textSize(14);
    textAlign(LEFT, TOP);
    text(entry, LX + border + 10 + 40, LY + border + 40 + 20, LW - border*2-75, LH - border*2); //25
    popStyle();
  }

  String showStatPage() {
    String entry = "";
    for (int i=0; i<8; i++) {
      entry+= '\n';
    }
    entry +=("Zombies Killed: " + zombiesKilled + '\n' +
      "Shots Fired: " + shotsFired + '\n' +
      "Items Found: " + itemsFound + '\n' + 
      "Items Used: " + itemsUsed + '\n' + 
      "Items Crafted: " + itemsCrafted + '\n' +
      "Buildings Entered: " + buildingsEntered + '\n' + 
      "Buildings Cleared: " + buildingsCleared + '\n' + 
      "Steps Taken: " + pixelsTravelled/40);

    pushStyle();
    noStroke();
    fill(#988C76);
    rectMode(CORNERS);
    rect(LX + border + 30, LY + border + 162 + 20, LX + LW-border-30, LY + LH-border-45);    // text box
    rect(LX + border + 30, LY + border + 30, LX + border + 35 + 110 + 20, LY + border + 35 + 110 + 20);  // picture box
    fill(#000000);
    textAlign(LEFT, BOTTOM);
    textSize(18);
    text("Name: " + you.name, LX+border+175, LY+border+75);
    String favText = "None";
    if (favWeapon != null) {
      favText = favWeapon.name + " with " + favWeapon.kills + " kills";
    }
    textSize(16);
    textAlign(LEFT, TOP);
    rectMode(CORNER);
    text("Favorite Weapon: " + '\n'+ favText, LX+border+175, LY+border+85, 200, 75);
    popStyle();
    return entry;
  }

  void display() {
    final color light = color(#766A54);
    final color dark = color(#554932);

    fill(dark);
    rect(LX, LY, LW, LH);
    fill(light);
    rect(LX + border, LY + border, LW - border*2, LH - border*2);
    showPage();
    fill(#000000);
    textFont(plain);
    textSize(12);
    textAlign(CENTER, BOTTOM);
    text((currPage+1) + " | " + pages.size(), LX+ LW/2, LH-15);

    //Binding (of Isaac)
    fill(#312E28);
    int bx = LX - 10;
    int by = LY + 40;
    int bw = 45;
    int bh = 8;

    for (int i = 0; i < 15; i++)
    {
      rect(bx, by, bw, bh);
      by += bh + 21;
    }
  }
}

void loadStory() {
  // loads a storyline
  StringList newStory = new StringList();

  int numLore = int(loadStrings("Lore/lore info.txt"))[0];  // turns the info.txt into a number array, and takes the first num
  for (int i=0; i<numLore; i++) {
    String newLore = loadText("Lore/lore" + i + ".txt");
    newStory.append(newLore);
  }

  storyline = newStory.array();
  loreNames = loadStrings("Lore/names.txt");
}

String loadText(String location) {
  String[] lines = loadStrings(location);
  String newLore = "";
  for (int i=0; i<lines.length; i++) {
    newLore += lines[i];
    newLore += '\n';
  }
  return newLore;
}

