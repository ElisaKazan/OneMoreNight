final float zombieSpeedMultiplier = 1.5;  // x% faster (1.x)
final float zombieToughness = 0.35;   // defend x% of damage (0.x)

float screenFade = 0;
int pauseTime = 0;
boolean goToSleep = false;
boolean wakeUp = false;

int attackingZombies;  // how many attacked that night
int minZombies, maxZombies;

int calcNightlyAttack(int night) {
  minZombies = int(pow(night, 2) - 3*night + 5);  // equation for zombies
  maxZombies = minZombies*2;
  return round(random(minZombies, maxZombies));
}

int calcNightlyDamages() { 
  return round(float(attackingZombies)/2.0);
}

void sleep(int night) {
  // triggers the night attack
  attackingZombies = calcNightlyAttack(night);    // gen zombies

  int numZombiesIn = max(0, attackingZombies - current.def);  // how many zombies get in the building
  int moraleNeeded = numZombiesIn*2;    // it takes 2% morale to fight off one zombie

  you.morale-= moraleNeeded;
  if (you.morale < 0) {  // dies
    deathReason = "Zombies got in, and you just couldn't take it any longer.";
    state = DEAD;
  }

  current.takeDamage(calcNightlyDamages());    // damage the building

  String nightReport = attackingZombies + " zombies attacked, ";
  if (numZombiesIn > 0) { 
    nightReport += numZombiesIn + " got in, and ";
  } else {
    nightReport += "and ";
  }
  nightReport += calcNightlyDamages() + " defense was lost during the night's attack.";
  console(nightReport);
  buildings.get(0).fillWithZombies(15);
}

