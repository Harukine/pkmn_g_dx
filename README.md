# Pokédex GO DX

Pokédex GO DX is a lightweight, offline-first Pokédex tailored for **Pokémon GO**.  
It parses Niantic's `GAME_MASTER` data to surface the most useful species and form
information in a clean Flutter UI, so you can browse the entire roster anywhere.

## Highlights
- 📋 Full species coverage with canonical Pokédex order
- 🔍 Sorting by name or Dex number, with instant navigation to detail pages
- 🧬 Rich form support (regional, costumed, shadow, mega, primal, etc.)
- 🎨 Consistent theming with Pokémon GO iconography from PokeMiners assets
- 📦 Single JSON payload means no runtime API dependency

## Data Pipeline
1. Download the latest `GAME_MASTER` payload from the Pokémon GO network dumps.
2. Run `assets/transform_game_master.py` to normalize the raw protobuf JSON into the
   simplified structures found under `data/`, merging `formSettings` metadata so costume
   and regional variants stay aligned with Niantic’s schema.
3. The Flutter app consumes `data/pokemon_go_slim.json` (referenced via
   `AppConstants.pokemonDataPath`) to build models such as `PokemonEntry` and
   `PokemonForm`, relying exclusively on `pogo_assets` icons for imagery.
4. Icon lookups cache their resolved URLs in `data/icon_cache.json`, so repeat transforms
   skip redundant HTTP HEAD calls (delete the file to force a full refresh).

> Tip: rerun the transform script whenever Niantic updates move stats, forms, or
> adds new species so your local Pokédex stays current.

## Getting Started
```bash
flutter --version        # ensure Flutter is installed
flutter pub get
flutter run              # pick ios, android, web, macos, windows, or linux
```

To regenerate the slim dataset:
```bash
python3 assets/transform_game_master.py \
  --input data/latest_game_master.json \
  --output data/pokemon_go_slim.json
```

## Key Modules
- `lib/services/pokemon_service.dart` – loads/caches the JSON and exposes sorting.
- `lib/models/` – strongly typed representations of species and form metadata.
- `lib/screens/list/` – main Pokédex list UI with sorting controls.
- `lib/screens/detail/` – deep dive into a single species, grouped by form type.
- `lib/widgets/` – reusable tiles, headers, and form cards.

## Roadmap
- Add search and filtering (type, region, tags, stats thresholds).
- Show move pools, raid utility, and IV breakpoints.
- Sync with live GAME_MASTER feeds or crowd-sourced APIs.
- Add widget/golden tests plus CI to prevent regressions.

---
Made with Flutter ❤️ for Pokémon GO trainers who want fast reference data without
hoping their internet connection holds up mid-raid.
