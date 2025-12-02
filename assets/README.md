# Pokemon GO Data Extraction

This directory contains the scripts used to extract and transform data for the Pokedex app.

## Core Scripts

### 1. `build_pokedex.py`
**The main entry point.** Run this script to generate the `pokemon_go_slim.json` file used by the app.
```bash
python assets/build_pokedex.py
```

### 2. `pokemon_extractor.py`
The core logic for extracting Pokemon data. It uses an **icon-first approach**:
1.  Loads all icons from `data/icon_manifest.json` (source of truth for forms).
2.  Matches icons to Game Master data.
3.  Creates synthetic forms for icons without Game Master entries (e.g., costumes).
4.  Adds Mega/Primal evolutions from Game Master `tempEvoOverrides`.

### 3. `icon_scraper.py`
Utility to scrape the latest icons from the PokeMiners repository. Run this if you need to update the icon manifest.
```bash
python assets/icon_scraper.py
```

## Data Flow
1.  **Icons**: `icon_scraper.py` -> `data/icon_manifest.json`
2.  **Game Master**: `data/latest_game_master.json` (Manual download or external source)
3.  **Extraction**: `build_pokedex.py` -> `pokemon_extractor.py` -> `data/pokemon_go_slim.json`

## Directory Structure
- `assets/`: Root for scripts
- `assets/utils/`: Shared utilities (Game Master loader, etc.)
- `data/`: Input/Output data directory
