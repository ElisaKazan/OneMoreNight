/*
  Preset tile settings so that the tiles can be easily saved on the map.
 Each preset will always have the same values for solid/container.
 Used so map can be saved as just a number
 */

final int WALL = 0;
final int FLOOR = 1;
final int CONT = 2;
final int SDECOR = 3;
final int HOUSEDOOR = 4;
final int IN_DOOR = 5;
final int OUT_DOOR = 6;

Presets[] tileType;

class Presets {
  boolean solid;
  boolean container;
  boolean transparent;

  Presets (String fromText) {
    String[] parts = fromText.split(",");
    solid = bool(parts[1]);
    container = bool(parts[2]);
    transparent = bool(parts[3]);
  }
}

void readPresets() {
  String [] lines = loadStrings("Maps/presets.txt");  // text file full of presets
  // splits up the text and arranges it into Preset() objects
  tileType = new Presets[lines.length];
  for (int i = 0; i<tileType.length; i++) {
    tileType[i] = new Presets(lines[i]);    // part[0] is just the name of the tile
  }
}

