- **Textbox1bpp**: TextboxBorder + TextboxPalette
- **Textbox2bpp**: _OverworldTextbox + TextboxPalette
- **SpeechTextbox1bpp**: Textbox1bpp with speech location and dimensions
- **SpeechTextbox2bpp**: Textbox2bpp with speech location and dimensions
- **PrintText1bpp**, **FarPrintText1bpp**: SpeechTextbox1bpp + print text
- **PrintText2bpp**: SpeechTextbox2bpp + print text
- **ClearTextbox**: Clear area of a speech textbox
- **MenuBox**: Calls Textbox1bpp or Textbox2bpp, depending on the value at wMenuBoxUse2bppFrame, with menu location and dimensions. wMenuBoxUse2bppFrame is cleared (FALSE means 1bpp) by ClearMenuAndWindowData as part of menu data.

- **OpenText1bpp**, **OpenText2bpp**: ClearMenuAndWindowData + ReanchorBGMap_NoOAMUpdate + SpeechTextbox1bpp + _OpenAndCloseMenu_HDMATransferTilemapAndAttrmap + Hide Window
  - **OpenText1bpp**: Loads 1bpp font (LoadFont_NoOAMUpdate: LoadFrame + LoadStandardFont)
  - **OpenText2bpp**: Doesn't load 2bpp font
- **RefreshScreen**: Same as OpenText functions but doesn't call any SpeechTextbox

- **Request1bpp**, **Request2bpp**: Copy 1bpp or 2bpp tiles at a rate of TILES_PER_CYCLE (8) per frame during vblank. Wait until complete
- **Copy1bpp**, **Copy2bpp**: Copy 1bpp or 2bpp tiles immediately
- **Get1bpp**, **Get2bpp**: Call Copy1bpp or Copy2bpp if LCD disabled. Request1bpp or Request2bpp otherwise
- **HDMATransfer1bpp**: Copy 1bpp tiles via HDMA. Maximum 16 tiles per frame.
- **HDMATransfer2bpp**: Copy 2bpp tiles via HDMA. No hardcoded limit. Timing considers 1 tile per hblank.
- **Get1bppViaHDMA**, **Get2bppViaHDMA**: Call Copy1bpp or Copy2bpp if LCD disabled. HDMATransfer1bpp or HDMATransfer2bpp otherwise

- **LoadFont_NoOAMUpdate**: LoadFrame + Hide Window + LoadStandardFont with OAM update disabled
- **LoadOverworldFont_NoOAMUpdate**: LoadOverworldFontAndFrame + hide Window with OAM update disabled
