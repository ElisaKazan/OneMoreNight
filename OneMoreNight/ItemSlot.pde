
//Global
final int ITEMS = 12;
ItemSlot[] inventorySlots = new ItemSlot[ITEMS];
boolean invShown = false;

class ItemSlot {
  int x;
  int y;

  ItemSlot(int x, int y)
  {
    this.x = x;
    this.y = y;
  }
} 

final int INVX = 35;
final int INVY = 30;
final int INVW = 600;
final int INVH = 500;
final int BOXW = INVW/6; 
final int BOXH = BOXW;

void showInventory() {
  textFont(plain); 
  final int text = 30;

  //Fill array with x and y values
  final int xSpace = 40;
  final int ySpace = 45;
  int tempx = INVX + xSpace;
  int tempy = INVY + ySpace + 20;

  for (int i = 0; i < ITEMS; i++) {
    inventorySlots[i] = new ItemSlot(0, 0);

    //x value
    inventorySlots[i].x = tempx;
    tempx += xSpace + BOXW;

    //y value
    inventorySlots[i].y = tempy;
    if (i == 3 || i == 7) {
      tempy += ySpace + BOXH;
      //Reset the x position
      tempx = INVX + xSpace;
    }
  }

  //Draws the box
  pushMatrix();
  resetMatrix();
  pushStyle();  
  rectMode(CORNER);

  //Draws the box
  if (crafting) {
    fill(#EA9A05);
    noStroke();
    rect(INVX-5, INVY-5, INVW+10, INVH+10);
  }

  fill(#766A54);
  stroke(#554932);
  strokeWeight(4);
  rect(INVX, INVY, INVW, INVH);

  //Draws each Box
  fill(#554932);
  textAlign(CENTER, TOP);
  imageMode(CORNER);
  Item currItem;
  for (int i = 0; i < ITEMS; i++) {
    if (crafting) {
      pushStyle();
      fill(#EA9A05);
      noStroke();
      if (selectedItems.hasValue(i)) {
        rect(inventorySlots[i].x-5, inventorySlots[i].y-5, BOXW+10, BOXH+10);
      }
      popStyle();
    }
    textSize(16);
    rect(inventorySlots[i].x, inventorySlots[i].y, BOXW, BOXH);  // background of slot
    if (you.inventory[i] != -1) {
      currItem = items.get(you.inventory[i]);
      image(currItem.pic, inventorySlots[i].x, inventorySlots[i].y);
      text(currItem.name, inventorySlots[i].x + BOXW/2, inventorySlots[i].y + BOXH + 10);
    }
  }      

  //Fancy Bar
  fill(#554932);
  noStroke();
  rect(INVX, INVY, INVW, text + 10);

  //Title
  textSize(25);
  fill(#C6B698);
  textAlign(CENTER, TOP);
  text("Inventory", INVX + INVW/2, INVY + 8);

  textSize(15);
  fill(#EA9A05);
  textAlign(CENTER, RIGHT);
  text("Craft (c)", INVX + INVW - 40, INVY + 25);

  popStyle();
  popMatrix();
}

