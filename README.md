# pokecrystal-board

pokecrystal-board is a single-player RPG board game engine for the GBC based on [pokecrystal](https://github.com/pret/pokecrystal).

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
  - The complete Pokemon battle engine
  - Pokemon data and storage
  - Item data and storage
  - ...

In pokecrystal-board **you will *not* find**:
- A ready-to-play game
- An engine that requires less ASM knowledge than the pokecrystal disassembly to develop features that don't yet exist
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

To suggest a feature or to report a bug, feel free to open an issue (using the "Feature suggestion" or "Bug report" labels) If you have specific questions about the usage of pokecrystal-board or how to contribute to it, feel free to reach me on Discord in the pret channel. But please, do not do this for questions that are rather in the domain of pokecrystal.

If you are interested on developing on top of pokecrystal-board, [docs/usage/index.md](docs/usage/index.md) details the different features. For generic changes made in pokecrystal-board (adaptations, cleaning up, etc.) refer to issues #1, #2, #7, #8. You can also navigate issues tagged with a "Feature" label to see commits pertaining specific features. Additionally, a rough list of new RAM addresses can be found in [docs/develop/ram_addresses.md](docs/develop/ram_addresses.md).

To get a quick feeling of the pokecrystal-board features, you can [watch these short videos](https://drive.google.com/drive/folders/1WW8HA_IAtl8MQlafNGip_66j1TEwL5qD?usp=drive_link). Alternatively, you can just build the debug ROM and check for yourself, but keep in mind that the configured data (maps, etc.) is purely dummy and merely added for testing purposes during development!