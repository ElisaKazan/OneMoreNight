
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.util.Map;    // hashmaps

PFont clock;
PFont plain;
PFont dayFont;
PFont titleFont;
PFont defaultFont;

AudioPlayer[] zombieMoans;
AudioPlayer[] zombieGrowls;
AudioPlayer[] nightBanging;
AudioPlayer nextPageSound;
AudioPlayer prevPageSound;
AudioPlayer test;
AudioPlayer song;
AudioPlayer meleeSwing;
AudioPlayer meleeHit;
AudioPlayer gunshot;
AudioPlayer theme;

PImage muzzleFlash;
PImage sleepingBag;

HashMap<String, PImage> tileMap = new HashMap<String, PImage>();

void setupAss() {
  //FONTS
  plain = loadFont("Fonts/SansSerif-20.vlw");
  clock = loadFont("Fonts/LetsgoDigital-Regular-48.vlw");
  dayFont = loadFont("Fonts/WantedM54-40.vlw");
  titleFont = loadFont("Fonts/FaceYourFears-48.vlw");

  zombieMoans = loadManySounds("Sounds/moan");
  zombieGrowls = loadManySounds("Sounds/growl");
  nightBanging = loadManySounds("Sounds/night");

  nextPageSound = minim.loadFile("Sounds/pageNext.mp3");
  prevPageSound = minim.loadFile("Sounds/pagePrev.mp3");
  meleeSwing = minim.loadFile("Sounds/swing.mp3");
  meleeHit = minim.loadFile("Sounds/hit.mp3");
  gunshot = minim.loadFile("Sounds/gunshot.mp3");

  test = minim.loadFile("Sounds/test.mp3");

  theme = minim.loadFile("DeepHaze.mp3");

  muzzleFlash = loadImage("flash.png");
  controls = loadImage("controls.png");
  title = loadImage("Title.png");
  gameover = loadImage("gameover.png");
  sleepingBag = loadImage("Sleeping Bag.png");

  //IMAGES
  // three keys used to load in the human readable tile names
  String[] buildKey;
  String[] tileKey;
  String[] variantKey;
  PImage temp;
  buildKey = loadStrings("Tiles/buildingKey.txt");
  for (int b=0; b<buildKey.length; b++) {
    tileKey = loadStrings("Tiles/" + buildKey[b] + "/tileKey.txt");
    for (int t=0; t<tileKey.length; t++) {
      variantKey = loadStrings("Tiles/" +buildKey[b] + "/" + tileKey[t] + "/variantKey.txt");
      for (int v=0; v<variantKey.length; v++) {
        temp = loadImage("Tiles/" + buildKey[b] + "/" + tileKey[t] + "/" + variantKey[v] + ".png");
        tileMap.put((str(b) + str(t) + str(v)), temp);
      }
    }
  }
}

