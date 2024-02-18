# pokecrystal-board

pokecrystal-board is a board game engine for the GBC based on [pokecrystal](https://github.com/pret/pokecrystal).

In pokecrystal-board **you will find**:
- Content with new built-in features
  - Overworld board game engine: menus, movement, events, turn lifecycle, etc.
  - Level selection menu ("world map")
  - Game progression logic
  - Other supporting features
- Empty canvas with pokecrystal-board placeholder content, or with no content
  - Actual levels and maps, and their design
  - Board space effects
  - Many GFX and SFX elements
  - Layout of transition screens and menus
  - ...
- Empty canvas with pokecrystal placeholder content
  - The complete battle engine
  - Pokemon data and storage
  - Item data and storage
  - ...

In pokecrystal-board **you will *not* find**:
- A ready-to-play game
- An engine that requires less ASM knowledge to use than the pokecrystal disassembly
- Guaranteed compatibility with extensions to pokecrystal developed by the community
- Definitive GFX and SFX assets for the pokecrystal-board features

**How can you use and what can you do with pokecrystal-board**:
- Use it as the base engine to develop your own game
- Develop new features or expand existing features for the purpose of your own game
- Develop new features or expand existing features to be incorporated into pokecrystal-board
- Design assets to be incorporated in place of the placeholder GFX/SFX in pokecrystal-board (see issue #9)
- Request or show your interest in specific features to be added to pokecrystal-board (open an issue for this)

Compared to pokecrystal and the Pokemon Crystal ROM, the ROM built by pokecrystal-board uses a MBC5 chip and requires 64 KB of RAM (8 banks of 8KB each).

pokecrystal-board requires RGBDS 0.7.0 to build. It has two build targets: *crystal*, and *crystal_debug*. The former builds a ROM with the *_DEBUG* symbol undefined, and the latter builds a ROM with the *_DEBUG* symbol defined. *crystal_debug* is meant to include additional content and configurations to facilitate testing during development, while *crystal* builds the ROM meant to be hypothetically released to the public. Other than that, refer to the [install docs from pokecrystal](INSTALL.md) for detailed instructions on how to setup and build pokecrystal-board.

If you have specific questions about the usage of pokecrystal-board or how to contribute to it, feel free to open an issue or to contact me on Discord. But please, do not do this for questions that are rather in the domain of pokecrystal.

If you are interested on developing on top of pokecrystal-board, the rest of this document details the different features. For generic changes made in pokecrystal-board (adaptations, cleaning up, etc.) refer to issues #1, #2, #7, #8. You can also navigate issues tagged with a "Feature" label to see commits pertaining specific features. Additionally, a rough list of new RAM addresses can be found in [docs/develop/index.md](docs/develop/index.md).

## Level selection menu

The level selection menu is essentially a world map that the player navigates to select a level to play. The player can move through landmarks that correspond to unlocked levels in the level selection menu. The level seleciton menu can have multiple map pages each with their own landmarks. When the player moves from a landmark in one page to a landmark in another page, the new page is loaded during the transition.

TODO: add image

The usual level:landmark relation is expected to be 1:1, but 1:n is also supported, for levels that may have alternative starting points.

The implementation is located in [engine/menus/level_selection_menu.asm](engine/menus/level_selection_menu.asm). GFX assets are included at the bottom of this file and point to [gfx/level_selection_menu](gfx/level_selection_menu):
- *LevelSelectionMenuGFX*: tile GFX shared by all the pages
- *LevelSelectionMenuPage\*Tilemap*: tilemap of each page
- *LevelSelectionMenuAttrmap*: attribute map shared by all the pages
- Various object graphics (direction arrows, etc.). These use *PAL_LSM_\** palettes.

A bunch of constants are defined for the level selection menu. These are mostly found in [constants/landmark_constants.asm](constants/landmark_constants.asm). Look out for those that start with or contain *LSM*.

The data is located in [data/levels/level_selection_menu.asm](data/levels/level_selection_menu.asm). This is how you design your level selection menu:
- *LevelSelectionMenu_Landmarks*: landmark data. Each entry uses a *level_selection_menu_landmark* macro and specifies, in this order: page number, x coordinate, y coordinate, landmark name, spawn point, level stages.
- *LevelSelectionMenu_LandmarkTransitions*: for each landmark, its transition data for each of the four directions, in down/up/left/right order (i.e. applicable to when the player presses the corresponding dpad key while in the landmark). Each entry contains direction/displacement pairs. Maximum displacement is 7; if you want a larger movement use e.g. DOWN, 7, DOWN, 3. Note that if the level that a given transition points to has not been unlocked, said transition won't be available.
- *LevelSelectionMenu_PageGrid*: layout of all pages in the big picture. Each byte entry is the page number, or -1 for no page.
- *LandmarkToLevelTable*: denotes the mapping between landmarks and levels.

## Overworld

The overworld uses a turn-based system. Each level is composed of one or more maps, and the maps are designed with spaces in them, which are meant for the player to move through them. Each turn the player rolls a die and advances spaces accordingly. Events may occur as appropriate while the player is advancing and/or when it lands in a space.

In addition to what is covered in this section, you can find more low level stuff about the pokecrystal-board overworld engine in the rough workflows described here: [docs/develop/index.md](docs/develop/index.md). The core of the overworld engine is in [engine/overworld/events.asm](engine/overworld/events.asm) and, in a way, the main logic occurs in *PlayerEvents*. New board logic in this context is in *CheckBoardEvent* and the state is defined by *BOARDEVENT_* constants. Again, for in-depth details refer to the aforementioned workflows or to the code itself.

### Board menu

The board menu is shown to the player at the beginning of each turn. In allows for several choices. The only ones that are specific to the pokecrystal-board engine are "roll die", "view map", and "exit level". The other three choices point to the party menu, bag menu, and pokegear, and are placeholders from pokecrystal. The board menu can be navigated horizontally. All menu options are accessed by selecting the corresponding icon of the menu, except for "view map" which is accessible via the Select button. All menu options except for "roll die" and "exit level" eventually return back to the board menu.

TODO: add image

The implementation is located in [engine/board/menu.asm](engine/board/menu.asm). Icon tiles are drawn over the background of the textbox as if they were font characters. The current menu item is highlighted with a colored overlay using objects. This file includes also the animation logic for rolling a die when the "roll die" option is selected. These animations leverage the overworld sprite animation engine from pokecrystal. Finally, [gfx/board](gfx/board) contains GFX assets.

### Board spaces

The spaces of each map are defined in the map file (in the [maps](maps) directory) under *\*_MapSpaces*. The definition of each space uses the *space* macro. An example:

```
DebugLevel2_Map2_MapSpaces:
	space  8, 12,  $0,  1 ;  0
	space  6, 12,  $0,  2 ;  1
	space  4, 12,  $0,  3 ;  2
	space  2, 12,  $0,  4 ;  3
	space  2, 10,  $0,  5 ;  4
```

The arguments of each *space* entry all take up one byte and are: x coordinate, y coordinate, space-specific data, id of next space.

The effects of each implemented type of board space are defined as scripts in [engine/board/spaces.asm](engine/board/spaces.asm). Examples include gaining coins, losing coins, getting items, starting a Pokemon battle, or choosing among branching paths in the board. A lot of these are placeholder and can be implemented or augmented according to your design intentions.

Board space effects are triggered from *PlayerEvents.CheckBoardEvent* during *BOARDEVENT_HANDLE_BOARD*. Each space tile uses a specific collision value (*COLL_\*_SPACE*), and the appropriate script is queued via *CallScript* for its later execution in *ScriptEvents*. Most space scripts have a check for whether the player has already landed on the space. But others (e.g. branch space, end space) trigger even if the player has not completed the movement. A branch space additionally does not count as an actual space in the movement (so it can't be landed on either).

When a player lands on a space, it turns into a "grey space" with no effect should the player land on it in a later turn.

#### Regular spaces

Regular space scripts have a check for whether the player has finished the movement according to the die roll and thus landed on the space. The actual effect is only executed when it is determined that the player has landed on the space.

#### Branch space

A branch space triggers even if the player has not completed the movement. A branch space additionally does not count as an actual space in the movement (so it can't be landed on either). In a branch space, the player is prompted to choose a direction to continue the movement. Some of these directions can be made locked until the player has unlocked a specific technique (Cut, Surf, etc.). Directions that can be followed are represented in the game with a colored arrow, whereas directions that are locked due to techniques are represented with a grey arrow.

The counterpart to a branch space is a union space. It is also noncounting and is used to denote convergence from multiple directions.

TODO: add image with branch space and union space

In a branch space, the last two bytes of the *space* macro are repurposed as a pointer to a branch struct with *branchdir* entries and ending with *endbranch*. For example:

```
	space  6, 12, .BS1    ;  2
	(...)

.BS1:
	branchdir LEFT,   13, 0
	branchdir UP,      3, TECHNIQUE_CUT | TECHNIQUE_SURF
	endbranch
```

Each *branchdir* entry includes: direction, next space id, techniques required. The order of entries is irrelevant, but do not put the same direction more than once in the same branch struct (all but the last entry using that direction will be ignored).

#### End space

Landing on an end space means that the player has cleared the level. Like the branch space, the end space effect triggers even if the player has not completed the movement. It transitions the player to a post-level screen (and then back to the level selection menu.)

The space-specific argument in the *space* entry of an end space indicates the stage of the level to be cleared by reaching this end space. An *ES\** constant from [constants/space_constants.asm](constants/space_constants.asm) is used for this.

### Board movement

The player moves in the board according to the next space id value of the last space passed through. Given ``SpaceA[NextSpaceId] = SpaceB``, if the movement to follow between SpaceA and SpaceB is linear (all steps in the same direction), the movement is automatic. On the other hand, for non-linear transitions between spaces (e.g. to make a turn or to avoid an obstacle), something called anchor events have to be used.

Anchor events are defined in *\*_MapEvents* under *def_anchor_points* in the map file. The next space id field of a space can instead represent a movement towards an anchor event by using a reserved value of *GO_DOWN*, *GO_UP*, *GO_LEFT*, or *GO_RIGHT* defined in [constants/space_constants.asm](constants/space_constants.asm). For example:

```
DebugLevel5_Map1_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_anchor_events
	anchor_event 10,  1, GO_RIGHT
	anchor_event 12,  1, 39
	(...)

DebugLevel5_Map1_MapSpaces:
	(...)
	space  8,  0,  $0, 38 ; 37
	space 10,  0,  $0, GO_DOWN ; 38
	space 12,  0,  $0, 40 ; 39
```

In the above example, space 38 at coordinates *10,0* specifies to go down, causing the anchor event at *10,1* to be matched after a step. An anchor event has a next space id field that can similarly represent a movement towards another anchor event. In this case, the anchor event at *10,1* points to go right, causing the anchor event at *12,1* to be reached. This anchor event points to space 39. Since space 39 is at *12,0*, a movement in the up direction will be automatically carried out, reaching space 39.

Note that if the next space id value of the last landed space or anchor event is an actual space id rather than a *GO_\** value, any anchor event that the player passes through in this movement will be ignored.

This simple board movement logic is located in [engine/board/movement.asm](engine/board/movement.asm) and is part of *DoPlayerMovement* in [engine/overworld/player_movement.asm](engine/overworld/player_movement.asm).

#### Warp events and connections

The player can traverse warps as part of a movement between two spaces, or cross the connection between two maps. The way you define map connections and warps in maps of pokecrystal-board is the same as in pokecrystal, and the underlying engine behind warps and connections is also the same.

Crossing maps has implications in space data, however. In the destination map of the warp of connection, you have to define an anchor event in exactly the landing coordinates in order to hook the player after traversing the warp or connection. In the origin map, the space immediately before the warp or connection has to use a *GO_\** constant that points in the right direction.

Imagine a warp between an origin map and a destination map. The origin map could for example have this:

	space  6, 10,  $0,  GO_UP ;  18

And the destination map could have this:

	anchor_event 19,  2,  0
	(...)
	space 20,  2,  $0,  1 ;  0

This matches that, in the origin map, upwards from the space 18 at coordinates *6,10* there is a warp event that causes the player to end up in destination map at coordinates *19,2*. The anchor event in the destination map denotes that the next space id is 0. Space 0 is at coordinates *20,2*, so it's just a linear movement of one step from where the anchor event is at.

Note that origin map and destination map could be the same map in the specific case of a warp pointing to another place in the same map. The same rules and logic apply regardless.

While the above example showcases a regular space, this same logic can be extrapolated to branch spaces using the *branchdir* macro explained beforehand.

#### Technique events

Technique events in pokecrystal-board represent the equivalent of hidden machines in Pokemon Crystal. A technique like Cut, Surf, Rock Smash, etc. can be unlocked through game progression (how exactly is unspecified), enabling what you can imagine i.e. cutting trees, surfing over water, smashing rocks, etc. Technique constants are defined in [constants/technique_constants.asm](constants/technique_constants.asm).

The main difference in pokecrystal-board is that techniques are executed in the overworld automatically. For example, when you are about to collide with a rock or tree, the corresponding technique handler is executed. This happens regardless of whether the technique is unlocked or not, in order to avoid the player getting stuck. This means that you should manage unlocked techniques by locking paths (in branch spaces) or levels until the required techniques have been unlocked.

Techniques are implemented in different manners. Cut and Rock Smash use objects entirely and are implemented through *CheckFacingTileEvent* in *PlayerEvents*, queuing the corresponding script. Surf (start/stop surfing) and Waterfall are also implemented in *CheckFacingTileEvent* alongside specific collision values carried over from pokecrystal. Flash is instead implemented as a map setup command.

### Object events

#### Trainer events

#### Talker events

### View map mode

### Map state preservation

## Game navigation and progression

## Other features

### Window HUD

### Overworld textbox

### RGB palette fading

### Tilesets

### OAM management

## Design aspects

This section covers miscellaneous design aspects not yet fully covered in other sections.

### Levels

### Game currency

### Time counting

### Game autosaving