/*
  Buildings contain the map of tiles, and info on the building. Outside is considered a building (building(0)) 
 */

// building types
final int HOUSE = 1;

int tilesAcross, tilesDown;  // saves how many tiles to draw across and down

boolean buildingOverviewShown = false;

ArrayList<Building> buildings;  // all the buildings
Building current;      // building you're in

class Building {
  int ID;
  int type;
  String name;
  Tile[][] map;
  int def, maxDef;
  int[] lootTable;
  ArrayList<Person> zombies;

  PVector spawn;
  PVector topCorner, bottomCorner;
  int rows, cols;
  String dir;
  int numClearTiles;   // this is used for figuring out how many zombies should be in a building

  Building(int id, int t, String direction) {
    ID = id;
    type = t;
    dir = direction;
    maxDef = round(random(90,110));
    def = round(random(40, 60));
    lootTable = loadLoot();
    zombies = new ArrayList<Person>();
  }

  boolean isEmpty() {
    if (zombies.size() == 0) return true;
    return false;
  }

  void readTile() {
    this.topCorner = new PVector(100000, 100000);
    this.bottomCorner = new PVector(-100000, -100000);
    String[] numVariants = loadStrings("Maps/Map Variants.txt");  // this stores how many of each building there are
    int curVariants = int(numVariants[type]);
    String[] lines = loadStrings("Maps/map" + this.type + this.dir + "-" +int(random(curVariants))+ ".txt");
    String[] parts;

    // first, figure out the 'size' of the current map, in terms of rows/cols
    this.rows = lines.length;    // rows is just the number of lines in the file
    this.cols = 0;
    for (int i=0; i<lines.length; i++) {
      parts = split(lines[i], ",");    // split each line into it's columns
      this.cols = max(this.cols, parts.length);  // the number of columns for the map needs to be the max column size of all the rows
    }

    // then create the map
    String temp;
    this.map = new Tile[cols][rows];
    for (int r=0; r<this.rows; r++) {
      parts = split(lines[r], ",");    // split the lines up
      for (int c=0; c<this.cols; c++) {
        if (c<parts.length) {          // since the rooms aren't perfectly aligned, some spots may be greater than the string
          temp = parts[c];
        } else {          // if this is the case, treat it as a wall
          temp = "0";
        }
        this.map[c][r] = new Tile(temp, c*tSize, r*tSize, this);
        if (this.map[c][r].type == OUT_DOOR) {  // this is to set the entrance spawn for a room
          this.spawn = new PVector(this.map[c][r].pos.x+tSize/2, this.map[c][r].pos.y+tSize/2);
        }
      }
    }
  }

  int[] loadLoot() {
    IntList loot = new IntList();
    String[] fullString = loadStrings("items/Text Files/locations.txt");
    String itemString = fullString[type];
    String[] parts = split(itemString, ",");

    name = parts[0];

    for (int i=1; i<parts.length; i++) {    // i = 0 is name
      if (parts[i].charAt(0) == '-') {    // if you're removing an item in the loot table
        String removing = parts[i].substring(1);
        if (loot.hasValue(nameToID(removing))) {
          for (int j=0; j<loot.size (); j++) {    // cycle through the list
            // j is spot in loot table
            int value = loot.get(j); // this gives us the item ID in the jTH slot of loot table
            if (value == nameToID(removing)) loot.remove(j);  // if the ID matches the item you're removing, remove it
          }
        }
      } else if (parts[i].equals("ALL")) {
        for (int j=0; j<items.size (); j++) {
          if (!items.get(j).special) {  // special items can't be found in chests
            loot.append(j);
          }
        }
      } else {
        loot.append(nameToID(parts[i]));
      }
    }
    return loot.array();
  }

  void fillWithZombies(int numZombies) {
    for (int i = 0; i<numZombies; i++) {
      zombies.add(new Person(ID));
    }
  }

  void takeDamage(int damage) {
    def = max(def-damage, 0);
  }

  void showMap() {
    rectMode(CORNER);
    imageMode(CORNER);
    int col = int((you.pos.x - current.topCorner.x)/tSize);
    int row = int((you.pos.y - current.topCorner.y)/tSize);
    for (int r=row-tilesDown; r<=row+tilesDown; r++) {  // draws from where you are, to half the tiles left right up down
      for (int c=col-tilesAcross; c<=col+tilesAcross; c++) {
        if (r>=rows || r<0 || c>=cols || c<0) continue;  // if it's out of bounds
        map[c][r].display(this);
      }
    }
    noStroke();
  }

  void showOverview() {
    pushStyle();
    rectMode(CORNER);
    stroke(#554932);
    strokeWeight(8);
    fill(#766A54);
    rect(INVX, INVY, INVW, INVH);
    fill(#C6B698);
    textFont(plain);
    textSize(26);
    textAlign(LEFT, TOP);
    text(name, INVX+15, INVY+15);
    textAlign(RIGHT, TOP);
    text("Max Def: " + maxDef, INVX + INVW-15, INVY+15);
    textAlign(CENTER, CENTER);
    text("Night " + (timeDay+1), INVX + INVW/2, INVY + 120);
    textSize(20);
    text("Zombies", INVX + INVW/4, INVY + 150);
    text("Defense", INVX + INVW*3/4, INVY + 150);
    textSize(24);
    text(minZombies + "-" + maxZombies, INVX + INVW/4, INVY + 175);
    text(def, INVX + INVW*3/4, INVY + 175);
    String warning;
    if (def < minZombies) {  // not even close
      warning = "You're gonna have a horrible night with those defenses.";
    } else if (def > maxZombies) { // super safe
      warning = "You should be fine.";
    } else { // in the middle
      warning = "You're really risking it eh? Good luck.";
    }
    if (!isEmpty()) warning = "Are you honestly gonna sleep with those zombies in here?";
    rectMode(CENTER);
    text(warning, INVX + INVW/2, INVY + 300, INVW - 100, INVH);
    imageMode(CENTER);
    image(sleepingBag, INVX + INVW/2, INVY + 420);
    fill(#766A54, 200);
    noStroke();
    if (day || !this.isEmpty()) ellipse(INVX + INVW/2, INVY + 420, sleepingBag.width, sleepingBag.height);
    popStyle();
  }
}

void enterBuilding() {
  // deals with moving into/out of buildings
  int c = int((you.pos.x - current.topCorner.x)/tSize);
  int r = int((you.pos.y - current.topCorner.y)/tSize);
  if (current.map[c][r].type == IN_DOOR) {  // if it's the entrance to the building
    // checks if the door has been entered before, if not
    // then generate a new building with the variant. if 
    // it has, then go to the variant.
    if (!current.map[c][r].opened) {
      current.map[c][r].opened = true;  // door has been opened  
      int newID = buildings.size();
      buildings.add(new Building(newID, current.map[c][r].variant, current.map[c][r].dir));  // add a new building
      current.map[c][r].variant = (buildings.size()-1);   // now set the door to point to the new building
      current = buildings.get(buildings.size()-1);  
      current.readTile();
      int numZombies = round(current.numClearTiles * (0.2 + random(-0.05, 0.05)));
      current.fillWithZombies(numZombies);
      buildingsEntered++;
    } else {
      current = buildings.get(current.map[c][r].variant);  // set the current building to the new one
    }
    you.outsidePos.set(you.pos);  // save your outside coords
    you.pos.set(current.spawn); // set yourself inside the door of the building
    you.whichBuilding = current.ID;
  } else if (current.map[c][r].type == OUT_DOOR) {    // if it's an exit
    current = buildings.get(0);
    you.pos.set(you.outsidePos);
    you.whichBuilding = 0;
    buildingOverviewShown = false;
  }
  areaFade = 500;
}

