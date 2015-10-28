// class is used for both zombies and people

// add stupid zombie to zombie collisions...

final int WANDER = 0;
final int CHASE = 1;

class Person {
  final int size = 20;
  PVector pos;
  PVector vel;
  float speed;
  int cooldown = 0;    // hit cooldown

  // "fist" stats
  final int baseDamage = 50;
  final int baseRange = 25;
  final int baseKnockback = 100;
  final int baseCooldown = 750; 
  final int zombieDam = 10;

  // player
  String name = "";
  PVector outsidePos;  // used when entering buildings
  float health, hunger, morale;
  float maxHealth = 100, maxHunger = 100, maxMorale = 100;
  int[] inventory = new int[12];  
  int equippedWeapon = -1;    // -1 means no item -> fists
  float flashTimer = 0;
  final float flashLength = 50;

  // zombie stuff
  float regularSpeed;
  float defense = 0;
  int awareness = 200;   // how far they can see you from
  boolean dead;
  int behavior;
  int whichBuilding;   // this is for what building the current entity is in
  float knockbackDistance = 0;
  PVector knockbackVel;
  final float knockbackSpeed = 4;
  int soundTimer;
  final int soundCooldown = 10000;
  AudioPlayer sound;

  Person(int x, int y) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    outsidePos = new PVector(0, 0);
    health = 100;
    hunger = 100;
    morale = 75;
    for (int i=0; i<inventory.length; i++) {
      inventory[i] = -1;
    }
    dead = false;
    speed = 2.75;
  }

  Person(int buildingID) {  // empty constructor for zombie
    pos = new PVector(0, 0);
    vel = new PVector(random(-1, 1), random(-1, 1));
    dead = true;
    regularSpeed = random(.25, 1.0) + random(.25, 1.0);  // between 0.5 and 2.0, highest chance for 1.25
    speed = regularSpeed;
    health = (1.25/speed) * 100;
    knockbackVel = new PVector(0, 0);
    behavior = WANDER;
    whichBuilding = buildingID;
    genValidCoords();
    soundTimer = int(random(soundCooldown));
    sound = null;
  }

  boolean isDead() {
    if (health <= 0) return true;
    return false;
  }

  // behaviors of both zombie and player ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void update() {
    if (this == you) {
      if (up && down) {
        vel.y = 0;
      } else if (up) {
        vel.y = -1;
      } else if (down) {
        vel.y = 1;
      } else {
        vel.y = 0;
      }

      if (left && right) {
        vel.x = 0;
      } else if (left) {
        vel.x = -1;
      } else if (right) {
        vel.x = 1;
      } else {
        vel.x = 0;
      }
      vel.normalize();
      vel.mult(speed);
    } else {  // zombie update
      // behaviors
      if (behavior == WANDER) {
        if (random(1) < .05) {
          wander();
        }
        if (random(1) < .05 && pos.dist(you.pos) < awareness) {
          scan();
        }
      } else if (behavior == CHASE) {
        if (random(1) < .05 && knockbackDistance == 0) {
          updateTarget(you.pos);
        }
      }

      if (isDead()) { 
        if (sound != null) {
          sound.pause();
          sound.rewind();
          sound = null;
        }
        current.zombies.remove(this);
        if (current.isEmpty()) buildingsCleared++;
      }

      if (sound != null) {
        if (sound.isPlaying()) { 
          sound.setGain(calcVolume());
        } else { 
          sound.rewind();
          sound = null;
        }
      }

      if (soundTimer <= 0 && random(1) < 0.01) emitSound();   // if can play sound, 1% to do it
      soundTimer-=deltaTime;

      if (dist(pos.x, pos.y, you.pos.x, you.pos.y) < baseRange - 5) attack();
    }

    isColliding();

    if (knockbackDistance == 0) {
      pos.add(vel);
      if (this == you) pixelsTravelled += vel.mag();
    } else {
      pos.add(knockbackVel);
      knockbackDistance = max(knockbackDistance - knockbackVel.mag(), 0);
    }
    cooldown = max(cooldown - deltaTime, 0);    // can't go below 0;
    flashTimer = max(flashTimer - deltaTime, 0);
  }

  boolean isColliding() {
    // checks collisions with the four touching tiles
    Building curBuilding = buildings.get(whichBuilding);

    // if they're being knocked back, they use a different velocity
    // so figure out the velocity being used and change that
    PVector currVel = vel;
    if (knockbackDistance != 0) currVel = knockbackVel;

    // create temporary variable storing the "next" position
    PVector nextPos = new PVector(pos.x + currVel.x, pos.y + currVel.y);


    // find your next square coords using next pos
    int c = int((nextPos.x - curBuilding.topCorner.x)/tSize);
    int r = int((nextPos.y - curBuilding.topCorner.y)/tSize);

    if (c < 0 || r < 0) return true;

    boolean hit = false;
    // then check the adjacent tiles
    if ((c+1 < curBuilding.cols) && (nextPos.x + size/2 > curBuilding.map[c+1][r].pos.x && curBuilding.map[c+1][r].solid) ||
      (c-1 >= 0) && (nextPos.x - size/2 + 1 < curBuilding.map[c-1][r].pos.x + tSize && curBuilding.map[c-1][r].solid)) {
      currVel.x = 0;
      hit = true;
    }
    if ((r+1 < curBuilding.rows) && (nextPos.y + size/2 > curBuilding.map[c][r+1].pos.y && curBuilding.map[c][r+1].solid) ||
      (r-1 >= 0) && (nextPos.y - size/2 + 1 < curBuilding.map[c][r-1].pos.y + tSize && curBuilding.map[c][r-1].solid)) {
      currVel.y = 0;
      hit = true;
    }
    if (hit) {
      knockbackDistance = 0;
      return true;
    }

    // then check the close corner of the four tiles on the corners 
    float toCorner = 1000;
    PVector curCorner = new PVector(0, 0);

    int fC = -1;
    int fR = -1;

    // top right tile -> bottom left corner
    if ((c+1 < curBuilding.cols && r-1 >= 0) && curBuilding.map[c+1][r-1].solid) {
      curCorner.set(curBuilding.map[c+1][r-1].pos.x, curBuilding.map[c+1][r-1].pos.y + tSize);
      if (toCorner > dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y)) {
        toCorner = dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y);
        fC = c+1;
        fR = r-1;
      }
    }
    // bottom right tile -> top left corner
    if ((c+1 < curBuilding.cols && r+1 < curBuilding.rows) && curBuilding.map[c+1][r+1].solid) {
      curCorner.set(curBuilding.map[c+1][r+1].pos.x, curBuilding.map[c+1][r+1].pos.y);
      if (toCorner > dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y)) {
        toCorner = dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y);
        fC = c+1;
        fR = r+1;
      }
    }
    // bottom left tile -> top right corner
    if ((c-1 >= 0 && r+1 < curBuilding.rows) && curBuilding.map[c-1][r+1].solid) {
      curCorner.set(curBuilding.map[c-1][r+1].pos.x + tSize, curBuilding.map[c-1][r+1].pos.y);
      if (toCorner > dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y)) {
        toCorner = dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y);
        fC = c-1;
        fR = r+1;
      }
    }
    // top left tile -> bottom right corner
    if ((c-1 >= 0 && r-1 >= 0) && curBuilding.map[c-1][r-1].solid) {
      curCorner.set(curBuilding.map[c-1][r-1].pos.x + tSize, curBuilding.map[c-1][r-1].pos.y + tSize);
      if (toCorner > dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y)) {
        toCorner = dist(curCorner.x, curCorner.y, nextPos.x, nextPos.y);
        fC = c-1;
        fR = r-1;
      }
    }

    if (toCorner < size/2-1) {    // if it found a close corner
      PVector fromCorner = new PVector(nextPos.x - (curBuilding.map[fC][fR].pos.x+tSize/2), nextPos.y - (curBuilding.map[fC][fR].pos.y + tSize/2));
      // fromCorner.set(nextPos.x - (curBuilding.map[fC][fR].x+tSize/2), nextPos.y - (curBuilding.map[fC][fR].y + tSize/2));
      currVel.set(fromCorner.x, fromCorner.y);
      currVel.normalize();
      pos.add(currVel);
      if (this != you && behavior == CHASE) updateTarget(you.pos);
      return true;
    }

    if (curBuilding.map[c][r].solid) {
      return true;
    }
    return false;
  }

  void attack() {
    if (cooldown == 0) {
      int inRange = baseRange;
      cooldown = baseCooldown;
      int dam = baseDamage;
      boolean isLoud = false;
      Item weapon = null;
      if (equippedWeapon != -1) {
        weapon = items.get(equippedWeapon);
        inRange = weapon.range;
        cooldown = weapon.cooldownTime;
        dam = weapon.damage;
        isLoud = weapon.loud;
      }

      if (this == you) {
        if (weapon != null && weapon.ranged) shotsFired++;
        if (isLoud) {
          // play sound
          gunshot.rewind();
          gunshot.play();

          // show flash
          flashTimer = flashLength;

          // alert nearby zombies
          Person zombie;
          for (int i=0; i<current.zombies.size (); i++) {
            zombie = current.zombies.get(i);
            if (you.pos.dist(zombie.pos) < 300) zombie.behavior = CHASE;
          }
        } else {
          meleeSwing.rewind();
          meleeSwing.play();
        }

        Person[] hit = hitOnLine(pos, mouse, inRange, this);
        if (hit.length > 0) {
          if (!isLoud) {
            meleeHit.rewind();
            meleeHit.play();
          }
          Person zombie = hit[0];    // hit first zombie
          zombie.knockedBack(you);   // knock it back
          zombie.health-=dam*(1-zombie.defense);  // damage it
          zombie.behavior = CHASE;      // behavior change
          if (zombie.isDead()) {     // then set kill stats
            zombiesKilled++;
            if (weapon != null) {
              weapon.kills++;
              favWeapon = findFavWeapon();
            }
          }
        }
      } else {
        you.health=max(0, you.health - zombieDam);
      }
    }
  }

  void display() {
    fill(#1CEA32); 
    if (dead) fill(#000000);
    if (debug && sound != null && sound.isPlaying()) fill(#159CAA);
    if (debug && behavior == CHASE) stroke(#FA082C);
    if (debug && this != you) {
      pushStyle();
      noFill();
      stroke(#FFFFFF);
      ellipse(pos.x, pos.y, awareness*2, awareness*2);
      popStyle();
    }
    ellipse(pos.x, pos.y, size, size);
    noStroke();
  }

  // player specific behavior ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  boolean getItem(int item) {
    // gives the player an item, returning false if no room
    Item recieve = items.get(item);
    if (recieve == lore) {  // if they found a lore item (this is checking the reference, as lore is an object)
      journal.addPage(storyline[journal.pages.size()-1]);
      return true;
    }

    for (int i=0; i<inventory.length; i++) {
      if (inventory[i] == -1) {
        inventory[i] = item;
        return true;
      }
    }
    return false;
  }

  void craft(IntList spots, Recipe curr) {
    // takes the spots of inventory and the crafting recipe and crafts it
    if (curr != null) {   // failsafe for non existant recipes
      for (int i : spots) {
        you.inventory[i] = -1;
      }
      this.getItem(curr.result);
      Item temp = items.get(curr.result);
      String itemName = indefiniteArticle(temp.name.toLowerCase()) + temp.name.toLowerCase();
      console("You crafted " + itemName + ".");
      itemsCrafted++;
    }
  }

  void showMuzzleFlash() {
    pushMatrix();
    PVector toMouse = new PVector(mouseX + 50 - width/2, mouseY - height/2);
    translate(width/2-50, height/2);
    rotate(toMouse.heading());
    image(muzzleFlash, 23, 5, 30, 15);
    popMatrix();
  }

  // zombie specific behavior ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void wander() {
    PVector wander = new PVector(vel.x, vel.y);
    wander.setMag(100);
    wander.x += random(-50, 50);
    wander.y += random(-50, 50);
    PVector newTarg = new PVector(pos.x+wander.x, pos.y+wander.y);
    updateTarget(newTarg);
    vel.setMag(1);
  }

  void scan() {
    Person[] canSee = hitOnLine(pos, you.pos, 250, this); // look at player
    // then find out if you saw player
    for (int i=0; i<canSee.length; i++) {
      if (canSee[i] == you) {
        behavior = CHASE;
        break;    // if you see them stop looking
      }
    }
  }

  void transform() {
    // alternates between night and day zombies
    if (day) {
      speed = regularSpeed;
      defense = 0;
    } else {
      speed = regularSpeed * zombieSpeedMultiplier;
      defense = zombieToughness;
    }
  }

  void updateTarget(PVector tar) {
    vel.set(tar.x  + random(-10, 10) - pos.x, tar.y  + random(-10, 10) - pos.y);
    vel.normalize();
    vel.mult(speed);
  }

  float calcVolume() {
    // calculates how loud the sound should be played, based on % of maxDist
    float maxDistance = dist(0, 0, width/2, height/2);
    float loudness = -50 * constrain(dist(you.pos.x, you.pos.y, this.pos.x, this.pos.y)/maxDistance, 0.0, 1.0);
    return loudness;
  }

  void emitSound() { 
    // plays a zombie sound
    if (behavior == WANDER) {
      sound = zombieMoans[int(random(zombieMoans.length))];
    } else if (behavior == CHASE) {
      sound = zombieGrowls[int(random(zombieGrowls.length))];
    }
    //    sound = test;
    if (!sound.isPlaying()) {
      sound.rewind();
      sound.setGain(calcVolume());
      sound.play();
      soundTimer = soundCooldown;
    } else {
      if (debug) println("sound failed - already playing " + random(1));
      sound = null;
    }
  }

  void knockedBack(Person hitter) {
    // sets the knocked back zombie's target in the direction of hit

    final float kBVariation = 0.2;

    // first, creates a vector from this to hitter
    PVector toHitter = new PVector(hitter.pos.x, hitter.pos.y);
    toHitter.sub(this.pos);
    // then flip it
    PVector knockback = new PVector(-toHitter.x, -toHitter.y);
    PVector newTarg = new PVector(this.pos.x, this.pos.y);
    newTarg.add(knockback);

    knockbackVel.set(newTarg.x  + random(-10, 10) - pos.x, newTarg.y  + random(-10, 10) - pos.y);
    knockbackVel.setMag(knockbackSpeed);

    // then set the knockback 'timer'
    knockbackDistance = hitter.baseKnockback;
    if (hitter.equippedWeapon != -1) {
      Item weapon = items.get(hitter.equippedWeapon);
      knockbackDistance = weapon.knockback;
    }

    knockbackDistance *= 1.0 + (random(-kBVariation, kBVariation));
  }

  void genValidCoords() {
    Building genBuilding = buildings.get(whichBuilding);
    float tempX = random(genBuilding.topCorner.x+size/2, genBuilding.bottomCorner.x-size/2);
    float tempY = random(genBuilding.topCorner.y+size/2, genBuilding.bottomCorner.y-size/2);
    int tempC = int((tempX - genBuilding.topCorner.x)/tSize);
    int tempR = int((tempY - genBuilding.topCorner.y)/tSize);
    while ( tempR>=genBuilding.rows || tempC>=genBuilding.cols || genBuilding.map[tempC][tempR].solid) {  // if you've generated a spot in a wall
      tempX = random(genBuilding.topCorner.x+size/2, genBuilding.bottomCorner.x-size/2);
      tempY = random(genBuilding.topCorner.y+size/2, genBuilding.bottomCorner.y-size/2);
      tempC = int((tempX - genBuilding.topCorner.x)/tSize);
      tempR = int((tempY - genBuilding.topCorner.y)/tSize);
    }
    this.pos.set(tempX, tempY);
    PVector toCenter = new PVector((genBuilding.map[tempC][tempR].pos.x + tSize/2) - pos.x, (genBuilding.map[tempC][tempR].pos.y+tSize/2) - pos.y);
    toCenter.normalize();
    int timer = 0;
    while (this.isColliding ()) { // if you're colliding, you're gonna get moved closer to the center of the curr tile
      pos.add(toCenter);
    }
  }
}

