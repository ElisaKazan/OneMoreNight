
int currChoice = 0; // keep track of cursor on title

PVector mouse = new PVector(mouseX, mouseY);

boolean up = false;
boolean left = false;
boolean down = false;
boolean right = false;

void keyPressed() {
  if (state == TITLE) 
  {
    if (key == CODED) 
    {
      if (keyCode == DOWN) currChoice = (currChoice+1)%options.length;
      if (keyCode == UP) 
      {
        currChoice--;
        if (currChoice < 0) currChoice = options.length-1;
      }
    }
    if (keyCode == ENTER) options[currChoice].choose();
  } else if (state == PAUSE && key == 'p') 
  {
    state = PLAY;
  } else if (state == CUSTOMIZE) {
    if (keyCode == ENTER) {
      state = PLAY;
    } else if (keyCode == BACKSPACE && you.name.length() > 0) {
      you.name = you.name.substring(0, you.name.length()-1);
    } else {
      you.name+= key;
    }
  } else if (state == PLAY) {
    if (key == 'p') {
      state = PAUSE;
    }

    if (key == CODED && journalShown) {
      if (keyCode == LEFT) journal.prevPage();
      if (keyCode == RIGHT) journal.nextPage();
    }

    switch (key) {

    case '-': // teleport
      you.genValidCoords();
      break;

    case 't': // day shift
      timeDay++;
      calcNightlyAttack(timeDay+1);
      break;

    case 'z':
      state = max(state-1, -3);
      cursor();
      soundtrack.pause();
      break;

    case 'b': // show building overview
      if (current.ID != 0) {
        if (buildingOverviewShown) {
          closeWindows();
        } else {
          closeWindows();
          buildingOverviewShown = true;
        }
      }
      break;

    case 'i':    // open inventory
      if (invShown) {
        closeWindows();
      } else {
        closeWindows();
        invShown = true;
      }
      break;

    case 'j': //open journal
      if (journalShown) {
        closeWindows();
      } else {
        closeWindows();
        journalShown = true;
      }
      break;  

    case 'c':   // crafting overlay, if inventory is shown
      if (invShown) {
        if (crafting) {
          crafting = false;
          selectedItems.clear();
        } else {
          crafting = true;
        }
      }
      break;

    case ESC:
      key = 0;
      closeWindows();      
      break; 

    case 'f':      // interact/search
      interact();
      break;

    case '9':    // developer hacks!
      you.getItem(int(random(items.size())));
      break;

    case '8': 
      you.getItem(nameToID("Bat"));
      you.getItem(nameToID("Police Baton"));
      you.getItem(nameToID("Crowbar"));
      you.getItem(nameToID("Machete"));
      you.getItem(nameToID("Shotgun"));
      you.getItem(nameToID("Pistol"));
      you.getItem(nameToID("Spiked Bat"));
      you.getItem(nameToID("Dual Pistols"));
      break;

    case '7':
      you.getItem(nameToID("Planks"));
      you.getItem(nameToID("Nails"));
      break;

    case 'w':
      up = true;
      break;

    case 's':
      down = true;
      break;

    case 'a':
      left = true;
      break;

    case 'd':
      right = true;
      break;
    }
  }
}

void keyReleased() {
  if (state == PLAY) {
    switch (key) {
    case 'w':
      up = false;
      break;

    case 's':
      down = false;
      break;

    case 'a':
      left = false;
      break;

    case 'd':
      right = false;
      break;

    case '2':
      state = DEAD;
      break;
    }
  }
}

void mouseClicked() {
  if (state == TITLE) {
    options[currChoice].choose();
  } else if (state == PLAY) {
    //If you are viewing the inventory
    if (invShown) {
      if (constrain(mouseX, 676, 791) == mouseX &&      
        constrain(mouseY, 339, 454) == mouseY) {      // unequipping weapon
        if (you.equippedWeapon != -1 && you.getItem(you.equippedWeapon)) you.equippedWeapon = -1;
      } else {
        for (int i = 0; i < ITEMS; i++)
        {        
          // finds out which (if any) spot was clicked
          if (mouseX > inventorySlots[i].x &&
            mouseX < inventorySlots[i].x + BOXW &&
            mouseY > inventorySlots[i].y &&
            mouseY < inventorySlots[i].y + BOXH)
          {
            if (you.inventory[i] != -1) {    // if there's an item there
              if (crafting) {    // if you are currently in crafting screen
                if (mouseButton == LEFT) {
                  if (!selectedItems.hasValue(i)) {
                    selectedItems.append(i);
                  } else {
                    you.craft(selectedItems, currCraft);
                    selectedItems.clear();
                  }
                } else if (mouseButton == RIGHT) {    // deselecting
                  if (selectedItems.hasValue(i)) {
                    int slot;
                    for (int j=0; j<selectedItems.size (); j++) {
                      slot = selectedItems.get(j);
                      if (slot == i) {
                        selectedItems.remove(j);
                        break;
                      }
                    }
                  }
                }
                currCraft = whichCraft(selectedItems);
              } else {
                Item temp = items.get(you.inventory[i]);
                if (mouseButton == LEFT) //Left click (normal)
                {
                  temp.use(i, false, you);
                } else if (mouseButton == RIGHT) //Right click (special)
                {
                  temp.use(i, true, you);
                }
              }
            }
          }
        }
      }
    } else if (buildingOverviewShown) {
      if (dist(mouseX, mouseY, INVX + INVW/2, INVY + 420) < sleepingBag.width/2 && !day) goToSleep = true;
    } else {
      mouse.set(mouseX, mouseY);
      mouse.sub(TRANS);
      you.attack();
    }
  } else if (state == CONTROLS ) 
  {
    state = TITLE;
  } else if (state == DEAD ) 
  {
    state = CREDITS;
  } else if (state == CREDITS ) 
  {
    resetGame();
    state = TITLE;
  }
}

