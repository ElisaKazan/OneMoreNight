
/*
  Tiles make up the map.
 */

final int tSize = 50;

class Tile {
  int type;      // which preset tile this is represented by, mostly used for image
  PVector pos;   // where it is 
  int variant;   // picture variation (eg floor could have 1 carpet, 2 hardwoord, 3 tile, etc). for doors, denotes which building type to go to
  boolean solid, transparent, search, opened;     // solid for collision, LoS/shooting, search for containers, and opened for IN_DOOR types
  int loot;
  String dir;   // this is just used for doors, to orient the outside building to the inside one
  Building build;

  Tile (String fromMap, float x, float y, Building build) { 
    pos = new PVector(x, y);
    String[] apart = split(fromMap, ".");
    type = int(apart[0]);
    if (apart.length == 3) {  // if the map has three pieces, it's a door
      variant = int(apart[1]);
      dir = apart[2].toUpperCase();  // the maps are saved with capitals, this is just to ensure it is capital
    } else if (apart.length == 2) {  // if the map part has two pieces, the second number is the variant
      variant = int(apart[1]);
    } else {    // if not, variant is just 0;
      variant = 0;
    }

    this.build = build;

    // uses the presets to assign values to the tile
    solid = tileType[type].solid;
    search = tileType[type].container;
    transparent = tileType[type].transparent;

    // build loot tables
    if (search) loot = build.lootTable[int(random(build.lootTable.length))];  

    // update the maps attributes
    current.topCorner.x = min(pos.x, current.topCorner.x);
    current.topCorner.y = min(pos.y, current.topCorner.y);
    current.bottomCorner.x = max(pos.x+tSize, current.bottomCorner.x);
    current.bottomCorner.y = max(pos.y+tSize, current.bottomCorner.y);
    if (!solid) current.numClearTiles++;
    // }
  }

  boolean scavenge() {
    Item item = items.get(this.loot);
    String lootName;

    if (item == lore) {
      if (journal.getSize() <= storyline.length) {  // if there's storyline left
        lootName = loreNames[journal.getSize()-1].toLowerCase();
        lootName = indefiniteArticle(lootName) + lootName;
        this.search = false;
        console("You search the container and find " + lootName + ". It was added to your journal.");
        you.getItem(loot);
        return true;
      } else {    // if you already have all the story parts
        while (item == lore) {    // gen non-lore item
          loot = build.lootTable[int(random(build.lootTable.length))];
          item = items.get(this.loot);
        }    // and then continue through the function
      }
    }

    lootName = item.name.toLowerCase();

    lootName = indefiniteArticle(lootName) + lootName;

    if (you.getItem(loot)) {
      this.search = false;
      console("You search the container and find " + lootName + ".");
      itemsFound++;
    } else {
      console("You find " + lootName + ", but don't have room.");
    }
    return false;
  }

  void display(Building build) {
    if (type == IN_DOOR || type == OUT_DOOR || type == HOUSEDOOR) {
      fill(#1816ED);
      rect(pos.x+TRANS.x, pos.y+TRANS.y, tSize, tSize);
    } else {
      PImage pic = tileMap.get(str(build.type) + str(type) + str(variant));
      image(pic, pos.x+TRANS.x, pos.y+TRANS.y, tSize, tSize);
    }
  }
}

Tile checkNearby(int searchType, PVector location, boolean middle, boolean surrounding) {
  // checks the adjecent tiles for the specified search type
  int col = int((location.x - current.topCorner.x)/tSize);
  int row = int((location.y - current.topCorner.y)/tSize);

  int foundR = -1;
  int foundC = -1;

  for (int r=row-1; r<=row+1; r++) {
    for (int c=col-1; c<=col+1; c++) {
      if (r<0||c<0||c>current.cols||r>current.rows) continue; //conditions in which tile is invalid
      if (!middle && (r==row && c==col)) continue;  // only if you're skipping the middle
      if (!surrounding && (r != row && c != col)) continue;   // if you're only checking the inside tile, skip the rest
      if (current.map[c][r].type == searchType) {
        if (foundR == -1 && foundC == -1) {  // if this is the first or only tile of it's type
          foundR = r;
          foundC = c;
        } else {  // this implies there's more than one of the selected type
          // need to pick the closest one
          float toFirst = dist(current.map[foundC][foundR].pos.x+tSize/2, current.map[foundC][foundR].pos.y+tSize/2, you.pos.x, you.pos.y);
          float toCurr = dist(current.map[c][r].pos.x+tSize/2, current.map[c][r].pos.y+tSize/2, you.pos.x, you.pos.y);
          if (toCurr < toFirst) { // if the new one is closer, and searchable
            foundR = r;
            foundC = c;
          }
        }
      }
    }
  }
  if (foundR > 0 && foundC > 0) {    // if you found a tile, return it
    return current.map[foundC][foundR];
  } else {
    return null;
  }
}

void interact() { 
  // check if you're entering/exiting a building first
  // first it checks the IN DOOR
  if (checkNearby(IN_DOOR, you.pos, true, false) != null || checkNearby(OUT_DOOR, you.pos, true, false) != null) {    
    enterBuilding();
  } else {    // if not, check the rest
    Tile container = checkNearby(CONT, you.pos, true, true);
    Tile door = checkNearby(HOUSEDOOR, you.pos, false, true); 
    if (container != null && door != null) {    // if both are found
      if (dist(container.pos.x+tSize/2, container.pos.y+tSize/2, you.pos.x, you.pos.y) >
        dist(door.pos.x+tSize/2, door.pos.y+tSize/2, you.pos.x, you.pos.y) || !container.search) {     // ->  door is closer
        door.solid = !door.solid;
        door.transparent = !door.transparent;
        console("You interact with the door.");
      } else {    // container is closer
        container.scavenge();
      }
    } else if (container != null) {
      if (container.search) {
        container.scavenge();
      } else {
        console("The container is empty.");
      }
    } else if (door != null) {
      door.solid = !door.solid;
      door.transparent = !door.transparent;
      console("You interact with the door.");
    } else {
      console("There's nothing nearby to interact with... you could try interacting with yourself?");
    }
  }
}

