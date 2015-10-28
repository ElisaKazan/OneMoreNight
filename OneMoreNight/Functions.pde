
boolean bool(String arg) {
  // used to take input from .txt file and turn into boolean
  if (arg.equals("t") || arg.equals("T") || arg.equals("1")) return true;
  return false;
}

int nameToID(String item) {
  // takes an item name and returns the ID, or -1 if not found
  Item temp;
  for (int i=0; i<items.size (); i++) {
    temp = items.get(i);
    if (temp.name.equals(item)) return i;
  }
  return -1;
}

boolean isVowel(char let) {
  // self explanitory
  switch (let) {
  case 'a':
  case 'e':
  case 'i':
  case 'o': 
  case 'u':
    return true;
  }
  return false;
}

String indefiniteArticle(String word) {
  // takes a noun and gives the proper indefinite article
  String article = "";
  if (word.charAt(word.length()-1) != 's') {  // is single item
    article += "a";
    if (isVowel(word.charAt(0))) {
      article += "n";
    }
    article += " ";
  }
  return article;
}

String correctFilePath(String path) {
  // takes a computer generated file path and converts into processing file path
  String corrected = "";
  for (int i=0; i<path.length (); i++) {
    if (path.charAt(i) == '\\') {    // if it finds a backslash (only one, double is to use \ in char)
      corrected+='/';
    } else {
      corrected+=path.charAt(i);
    }
  }
  return corrected;
}

void fileSelected(File selected) {
  if (selected != null) {
    String path = correctFilePath(selected.getAbsolutePath());
    if (path.substring(path.length()-4, path.length()).equals(".mp3")) {  // only play songs
      song = minim.loadFile(path);
      song.play();
      song.setGain(-15);
    }
  }
  state = PLAY;
}

Person[] hitOnLine(PVector pos, PVector target, int range, Person seeker) {
  // makes a straight line from pos to target, and returns all Person's on the line
  // stops if it hits a wall
  ArrayList<Person> hitPeople = new ArrayList<Person>();
  IntList alreadyHit = new IntList();    // this keeps track of which zombies have already been hit
  PVector step = target.get();
  step.sub(pos);
  step.setMag(3);
  PVector curPos = pos.get();
  boolean playerHit = false;

  int numSteps = ceil(range/step.mag());

  int c, r;

  for (int s=0; s<numSteps; s++) {
    curPos.add(step);

    c = int((curPos.x - current.topCorner.x)/tSize);
    r = int((curPos.y - current.topCorner.y)/tSize);

    if (!current.map[c][r].transparent) break;    // if it hits a wall, end

    if (you.whichBuilding == current.ID && you.pos.dist(curPos) < you.size/2 && !playerHit && you != seeker) {
      hitPeople.add(you);
    }

    Person zombie;
    for (int z=0; z<current.zombies.size (); z++) {
      zombie = current.zombies.get(z);
      if (zombie.whichBuilding == current.ID && zombie.pos.dist(curPos) < zombie.size/2 && !alreadyHit.hasValue(z) && zombie != seeker) {
        hitPeople.add(zombie);
        alreadyHit.append(z);
      }
    }
  }

  Person hitArray[] = new Person[hitPeople.size()];
  Person temp;
  for (int i=0; i<hitPeople.size (); i++) {
    temp = hitPeople.get(i);
    hitArray[i] = temp;
  }

  return hitArray;
}

AudioPlayer[] loadManySounds(String text) {
  // loads as many sounds as possible in the format text#.mp3
  ArrayList<AudioPlayer> list = new ArrayList<AudioPlayer>();

  int num = 1;
  File next = dataFile(text + num + ".mp3");  // "loads" a file
  while (next.exists ()) {    // if it exists, load the soundfile
    list.add(minim.loadFile(text+num+".mp3"));
    num++;
    next = dataFile(text+num+".mp3"); 
    // then cycles through until it finds one that doesn't exist
  }

  // then turns into an array
  AudioPlayer[] array = new AudioPlayer[list.size()];
  for (int i=0; i<array.length; i++) {
    array[i] = list.get(i);
  }

  return array;
}

void closeWindows() {
  // closes all HUD windows opened
  buildingOverviewShown = false;
  journalShown = false;
  invShown = false;
  crafting = false;
  selectedItems.clear();
}

void resetGame() {
  // regen buildings
  buildings.clear();
  buildings.add(new Building(0, 0, "N"));  // 0 is outside

  // recreate outside
  current = buildings.get(0);
  current.readTile();
  int numZombies = 100;
  current.fillWithZombies(numZombies);

  words1 = "";
  words2 = "";
  words3 = "";
  words4 = "";

  // new journal
  journal = new Journal();
  journal.addPage("");
  journal.addPage(storyline[0]);

  // night stuff reset
  wakeUp = false;
  goToSleep = false;
  timeDay = 0;
  nightWarning = true;
  countdown = dayLength;
  calcNightlyAttack(1);

  // stat reset
  zombiesKilled = 0;
  itemsFound = 0;
  itemsCrafted = 0;
  itemsUsed = 0;
  shotsFired = 0;
  buildingsEntered = 0;
  buildingsCleared = 0;
  pixelsTravelled = 0;
  favWeapon = null;
  for (Item item : items) item.kills = 0;

  // reset you
  you.whichBuilding = 0;
  you.genValidCoords();
  you.name = "";
  you.health = 100;
  you.hunger = 100;
  you.morale = 75;
  // clear inventory
  for (int i=0; i<you.inventory.length; i++) you.inventory[i] = -1;
  you.equippedWeapon = -1;

  textYPos = height;
}

