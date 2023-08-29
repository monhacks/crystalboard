### Functions

#### Apply VRAM/OAM

- **SafeUpdateSprites**: Set BG map mode to 0 (disabled) and disable OAM update + UpdateSprites + enable OAM update + DelayFrame + restore original state of BG map mode and OAM update
- **UpdateSprites**: Compute state of overworld sprites to wShadowOAM. Disable OAM update while editing wShadowOAM, and restore its original state when finished
- **ApplyPals**: Copy wBGPals1 into wBGPals2 and wOBPals1 into wOBPals2. Does not request pal update during vblank by itself
- **ApplyAttrmap**: Set BG map mode to 2 (pals) and delay 4 frames, and finally restore original state BG map mode. If LCD disabled instead copy all pals at once immediately
- **ApplyTilemap**: Set BG map mode to 1 (tiles) and delay 4 frames. If wSpriteUpdatesEnabled is non-0, instead call CopyTilemapAtOnce to do it all in one frame. This delays the next vblank to LY ~$7f

#### Load font

- **LoadFont_NoOAMUpdate**: LoadFrame + Hide Window + LoadStandardFont with OAM update disabled
- **LoadOverworldFont_NoOAMUpdate**: LoadOverworldFontAndFrame + hide Window with OAM update disabled

#### Textboxes

- **Textbox1bpp**: TextboxBorder + TextboxPalette
- **Textbox2bpp**: _OverworldTextbox + TextboxPalette
- **SpeechTextbox1bpp**: Textbox1bpp with speech location and dimensions
- **SpeechTextbox2bpp**: Textbox2bpp with speech location and dimensions
- **ClearTextbox**: Clear the inside of a speech textbox (fill with " ")
- **PrintTextboxText**: Print text in speech textbox coordinates with letter delay
- **PrintText1bpp**, **FarPrintText1bpp**: SpeechTextbox1bpp + UpdateSprites + ApplyTilemap + ClearTextbox + PrintTextboxText
- **PrintText2bpp**: SpeechTextbox2bpp + UpdateSprites + ApplyTilemap + ClearTextbox + PrintTextboxText
- **MapTextbox**: ClearTextbox + redraw tile behind cursor + SafeUpdateSprites + disable OAM update + ApplyTilemap + PrintTextboxText + enable OAM update
- **MenuBox**: Calls Textbox1bpp or Textbox2bpp, depending on the value at wMenuBoxUse2bppFrame, with menu location and dimensions. wMenuBoxUse2bppFrame, as part of menu data, is cleared (FALSE means 1bpp) by ClearMenuAndWindowData

#### Overworld map scrolling

- **LoadScreenTilemap**: From the metatile-based 24x20 map in wSurroundingTiles, load the corresponding 20x18 tiles to wTilemap. Later, BackupBGMap* from ScrollMap* copies new row/column from wTilemap to wBGMapBuffer. _ScrollBGMapPalettes populates wBGMapPalBuffer based on the tiles at wBGMapBuffer. These are read during vblank by UpdateBGMapBuffer.
- **LoadScreenAttrmapPals**: Load wAttrmap palette numbers based on the tileset palettes of the current map. Called only by LoadScreenTilemapAndAttrmapPals.
- **LoadScreenTilemapAndAttrmapPals**: LoadScreenTilemap + LoadScreenAttrmapPals. Often used to reload screen after closing a text box.

#### Overworld map anchoring

- **ReanchorBGMap_NoOAMUpdate**: LoadScreenTilemapAndAttrmapPals + HDMATransferTilemapAndAttrmap_OpenAndCloseMenu, then fill BG map with all black while Window is displayed, finally anchor map and objects. Shall by followed by CopyTilemapAtOnce or by a HDMATransferTilemapAndAttrmap_* to redraw the screen.
- **OpenText1bpp**, **OpenText2bpp**: ClearMenuAndWindowData + ReanchorBGMap_NoOAMUpdate + SpeechTextbox1bpp + HDMATransferTilemapAndAttrmap_OpenAndCloseMenu + hide Window
  - **OpenText1bpp**: Loads 1bpp font (LoadFont_NoOAMUpdate)
  - **OpenText2bpp**: Doesn't load 2bpp font
- **RefreshScreen**: Same as OpenText functions but doesn't call any SpeechTextbox

#### VRAM transfer

- **Request1bpp**, **Request2bpp**: Copy 1bpp or 2bpp tiles at a rate of TILES_PER_CYCLE (8) per frame during vblank. Wait until complete
- **Copy1bpp**, **Copy2bpp**: Copy 1bpp or 2bpp tiles immediately
- **Get1bpp**, **Get2bpp**: Call Copy1bpp or Copy2bpp if LCD disabled. Request1bpp or Request2bpp otherwise
- **HDMATransfer1bpp**: Copy 1bpp tiles via HDMA. Maximum 16 tiles per frame
- **HDMATransfer2bpp**: Copy 2bpp tiles via HDMA. No hardcoded limit. Timing considers 1 tile per hblank
- **Get1bppViaHDMA**, **Get2bppViaHDMA**: Call Copy1bpp or Copy2bpp if LCD disabled. HDMATransfer1bpp or HDMATransfer2bpp otherwise
- **HDMATransferTilemapAndAttrmap_OpenAndCloseMenu**, **HDMATransferTilemapAndAttrmap_OverworldEffect**: Similar, but with slightly different scanline timing. So they're essentially like RefreshScreen minus the anchoring part.

#### HUD

- **EnableWindowHUD**: Configure LCD interrupt in LYC=LY mode with corresponding LYC
- **DisableWindowHUD**: Configure LCD interrupt in hblank mode
- **LoadHUD**: Load the HUD at wWhichHUD to the top of wTilemap and wAttrmap
- **LoadWindowHUD**: Like LoadHUD, but for HUDs that require a Window overlay. Only does anything if hWindowHUDLY is non-0
- **ConstructOverworldHUDTilemap**: Draw the overworld HUD's tilemap into wOverworldHUDTiles
- **TransferOverworldHUDToBGMap**: Transfer overworld HUD to vBGMap1/vBGMap3 during v/hblank(s). Tilemap is read from wOverworldHUDTiles, attrmap is all PAL_BG_TEXT | PRIORITY.

### Scripts

- **refreshscreen**: RefreshScreen
- **reloadmappart**: LoadScreenTilemapAndAttrmapPals + GetMovementPermissions + HDMATransferTilemapAndAttrmap_OverworldEffect + UpdateSprites. Similar to refreshscreen, but does not reanchor. On the other hand, it refreshes movement permissions. Often used after a block change or field move, which can affect collisions.
