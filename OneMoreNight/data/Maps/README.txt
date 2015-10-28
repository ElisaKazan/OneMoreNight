Maps are saved as map[building Type][direction]-[variant]
This is so the program opens the right maps for the
right buildings, and ensures the exteriors are in line
with the interior.

The Map Variants.txt contains how many unique map type (each building) maps there are currently. The row number = building num
Eg, House1, 2, 3:
map1L-0, map1L-1, map1L-2

In the maps, the presets.txt dictate collision/search
booleans. Where in the text (line 0, line 1, etc)
dictates what the numbers in the maps represent

the decimals in the map tiles are for two things:
if they have 2 decimals, it is an outside door.
	They are created like maps: door[building][dir].
	Eg 6.3.U
	This will possibly be updated later so the 
	program sets it's own direction.
If they have 1 decimal, it's just the variation of the tile
	tile, wood, carpet etc.
