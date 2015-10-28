
final int CONSUME = 0;
final int WEAPON = 1;
final int MATERIAL = 2;
final int REINFORCE = 3;

ArrayList<Item> items;

class Item {
  int type;   // weapon vs consumable
  String name;
  PImage pic;
  boolean special;   // special items can't be found in chests

  // consumables
  int healthEffect, hungerEffect, moraleEffect;
  String action;

  // weapons
  int damage;   
  int range;
  int cooldownTime;
  int knockback;
  boolean loud;
  boolean ranged;
  int kills = 0;

  // reinforcements
  int defEffect, maxDefEffect;

  Item(int t, String fromText) {
    type = t;
    String[] parts = fromText.split(",");  // split the incoming string
    // each of the types are loaded differently
    special = false;
    name = parts[0];    // but name is always first
    pic = loadImage("Items/" + name + ".png");
    if (type == CONSUME) {
      healthEffect = int(parts[1]);
      hungerEffect = int(parts[2]);
      moraleEffect = int(parts[3]);
      action = parts[4];
    } else if (type == WEAPON) {
      damage =  int(parts[1]);
      range = int(parts[2]);
      cooldownTime = int(float(parts[3])*1000);
      knockback = int(parts[4]);
      loud = bool(parts[5]);
      ranged = bool(parts[6]);
    } else if (type == REINFORCE) {
      defEffect = int(parts[1]);
      maxDefEffect = int(parts[2]);
    }
  }

  Item () {  // empty constructor for lore item
    name = "Lore";
  }

  void use(int slot, boolean discard, Person user) {

    String connectingWord = " was ";
    // find out if the word is were/was
    if (name.charAt(name.length() - 1) == 's') {   // if it's multiple
      connectingWord = " were ";
    }

    if (!discard) {
      if (type == CONSUME) {
        if (name.equals("Music Player")) {
          selectInput("Pick a song!", "fileSelected");
          state = PAUSE;
          theme.pause();//pauses theme
        }
        user.inventory[slot] = -1;
        user.health = constrain(user.health + healthEffect, 1, user.maxHealth);
        user.hunger = constrain(user.hunger + hungerEffect, 1, user.maxHunger);
        user.morale = constrain(user.morale + moraleEffect, 1, user.maxMorale);
        console(name + connectingWord + action + ".");
        itemsUsed++;
      } else if (type == WEAPON) {
        int temp = user.equippedWeapon;    // keep track of previous weapon
        user.equippedWeapon = user.inventory[slot];  // give user new weapon
        user.inventory[slot] = -1;  // remove it from inventory
        if (temp != -1) user.getItem(temp);   // if user had a weapon, give it back
        console(name + connectingWord + "equipped.");
      } else if (type == REINFORCE) {
        if (current.ID != 0) {      // can't reinfoce outside
          if (current.isEmpty()) {  // or in zombie filled buildings
            if (current.def < current.maxDef) {  // if there's room to upgrade
              user.inventory[slot] = -1;
              current.maxDef += maxDefEffect;
              current.def = constrain(current.def+defEffect, 0, current.maxDef);
              console(name + connectingWord + "used to upgrade the building.");
            } else {   // trying to upgrade beyond max
              console("The " + name + " won't have any effect. Upgrade the foundation instead.");
            }
          } else {  // if it's not empty
            console("\"I should probably clear out this building first...\"");
          }
        } else {  // if it's outside
          console("OAK: "+ user.name+ "! This isn't the time to use that!");
        }
      }
    } else {
      user.inventory[slot] = -1;
      console(name + connectingWord + "discarded.");
    }
  }
}

void loadItems() {
  // loads each of the item text files
  String[] itemText = loadStrings("Items/Text Files/consumables.txt");
  addItems(itemText, CONSUME);
  itemText = loadStrings("Items/Text Files/weapons.txt");
  addItems(itemText, WEAPON);
  itemText = loadStrings("Items/Text Files/materials.txt");
  addItems(itemText, MATERIAL);
  itemText = loadStrings("Items/Text Files/reinforcements.txt");
  addItems(itemText, REINFORCE);
  makeSpecials();
}

void addItems(String[]lines, int type) {
  for (int i=1; i<lines.length; i++) {  // skips first entry, it is the legend for the txt
    items.add(new Item(type, lines[i]));
  }
}

void makeSpecials() {
  // takes the specials text and makes the listed items special
  String[] specials = loadStrings("Items/Text Files/specials.txt");
  for (String name : specials) items.get(nameToID(name)).special = true;
}

Item findFavWeapon() {
  int curHighest = 0;
  Item favWeapon = null;
  Item temp;
  for (int i=0; i<items.size (); i++) {
    temp = items.get(i);
    if (temp.type == WEAPON && temp.kills > curHighest) {
      curHighest = temp.kills;
      favWeapon = temp;
    }
  }
  return favWeapon;
}

