/*  Current Problems/Necessary Add-ons
 
 - BALANCE
 - make maps
 - make tiles
 - story
 
 - tutorial 
 - >> zombie nearby
 - >> weapon/inv management
 - >> crafting
 
 - increase number of weapon sounds/art
 
 - character customization
 - >> load in picture?
 - >> name
 
 For the future:
 
 - Combat
 - >> range types: straight, spread, throw
 - >> ammo?
 - >> accuracy?
 - >> hit animation (gun shot, swing)
 
 - misc lore
 - >> previous players stats as lore!! :D
 
 - better zombie targetting
 - >> maybe based on direction, like in tut
 
 - Person inheritance
 - >> person: zombie, player, npc?
 */

boolean debug = false;

Person you;

float updateRadius;    // only update zombies that are within this area

PImage controls;
PImage title;
PImage gameover;

void setup() {
  size(800, 650);

  ArrayList<Option> tempOptions = new ArrayList<Option>();
  tempOptions.add(new Option("Play", CUSTOMIZE));
  tempOptions.add(new Option("Controls", CONTROLS));
  tempOptions.add(new Option("Credits", CREDITS));
  tempOptions.add(new Option("Quit", QUIT));
  options = new Option[tempOptions.size()];
  for (int i=0; i<options.length; i++) {
    options[i] = tempOptions.get(i);
  }

  setupTitle();

  tilesAcross = ceil(width/tSize/2);
  tilesDown = ceil(height/tSize/2)+1;
  updateRadius = dist(width/2, height/2, width, height) * 1.2;

  countdown = dayLength;

  setupAss();
  theme.play();
  theme.loop();
  readPresets();

  items = new ArrayList<Item>();
  lore = new Item();
  items.add(lore);
  loadItems();

  recipes = new ArrayList<Recipe>();
  selectedItems = new IntList();
  loadRecipes();

  buildings = new ArrayList<Building>();
  buildings.add(new Building(0, 0, "N"));  // 0 is outside

  current = buildings.get(0);
  current.readTile();
  int numZombies = 100;
  current.fillWithZombies(numZombies);

  TRANS = new PVector(0, 0);
  you = new Person(width/2, height/2);
  you.genValidCoords();

  loadStory();

  journal = new Journal();
  journal.addPage("");
  journal.addPage(storyline[0]);
  calcNightlyAttack(1);
}

void draw() {
  if (state == TITLE) {
    titleScreenChange();
  } else if (state == CUSTOMIZE) {
    customize();
  } else if (state == PLAY) {
    play();
  } else if (state == CONTROLS) {
    instructions();
  } else if (state == PAUSE) {
    pause();
  } else if (state == DEAD) {
    dead();
  } else if (state == CREDITS) {
    creditScreen();
  } else if (state == QUIT) {
    exit();
  }
  deltaTime = millis() - time;
  if (state == PLAY && day) countdown -= deltaTime;
  time = millis();
}

