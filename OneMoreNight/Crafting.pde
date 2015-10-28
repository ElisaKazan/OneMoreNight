
boolean crafting;  // for the crafting overlay
IntList selectedItems;
Recipe currCraft = null;

ArrayList<Recipe> recipes;

class Recipe {
  int[] materials;
  int result;

  Recipe (String fromString) {
    String[] parts = fromString.split(",");
    IntList matList = new IntList();   // using an intlist so can sort
    for (int i = 0; i<parts.length-1; i++) {
      matList.append(nameToID(parts[i]));
    }
    matList.sort();    // sorting the recipes makes crafting much easier
    materials = matList.array();
    result = nameToID(parts[parts.length-1]);
  }
}

void loadRecipes() {
  String[] lines = loadStrings("Items/Text Files/crafting.txt");
  for (int i=0; i<lines.length; i++) {
    recipes.add(new Recipe(lines[i]));
  }
}

Recipe whichCraft(IntList inputSlots) {
  // returns a crafting recipe, if none found, null;

  IntList inputItems = new IntList();

  for (int i : inputSlots) {
    inputItems.append(you.inventory[i]);
  }

  inputItems.sort();    // sort the array so it'll match up with the sorted recipes
  int[] arInput = inputItems.array();
  Recipe temp;
  for (int i=0; i<recipes.size (); i++) {
    temp = recipes.get(i);

    if (arInput.length != temp.materials.length) continue;     // if it's not the same size, skip

    for (int j=0; j<=arInput.length; j++) {    // cycle through the inputted items
      if (j==arInput.length) return temp;     // if you've reached the end of the list, you've found a match
      if (arInput[j] != temp.materials[j]) break;  // if there's a missing/not equal part, it's not this recipe
    }
  }
  return null;
}

