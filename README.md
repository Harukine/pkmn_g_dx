# Pokédex GO DX

Pokédex GO DX is a high-performance, offline-first Pokédex engineered specifically for **Pokémon GO**. It transforms Niantic's `GAME_MASTER` data into a fluid, responsive Flutter experience with zero runtime API dependency.

## Highlights

- 📋 Full species coverage with canonical Pokédex order
- 🔍 Search, filtering by type, and sorting by name or Dex number
- 🧬 Rich form support — regional, costumed, shadow, mega, primal, Dynamax, and more
- 🎨 Dark-themed UI with type-reactive color system and Pokémon GO iconography
- 📦 Single JSON payload — no runtime API calls, works fully offline
- ⚡ Background isolate processing for 60fps filtering across 1,000+ entries

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x |
| **State Management** | Riverpod 3.0 (`FutureProvider`, `StateProvider`) |
| **Image Caching** | `CachedNetworkImage` (unified on all platforms including Web) |
| **Data Pipeline** | Python 3.11+ |

## Architecture

### Background Filtering
All search, filter, and sort operations are offloaded to a background isolate via Flutter's `compute()`. The UI thread is never blocked, even when the full 1,000+ Pokémon list is active.

### O(1) Pokémon Lookup
On load, `PokemonService` builds an in-memory index (`_idIndex`) keyed by all IDs and form aliases. Every lookup is constant-time regardless of roster size.

## Data Pipeline

The dataset is built from Niantic's public `GAME_MASTER` using a two-stage icon-first pipeline:

## Getting Started

```bash
flutter pub get
flutter run          # targets: iOS, Android, Web, macOS, Windows, Linux
```

## Key Modules

| Path | Role |
|---|---|
| `lib/services/pokemon_service.dart` | Loads & indexes the JSON asset; memoizes evolution chains |
| `lib/providers/pokemon_providers.dart` | Riverpod providers: data loading, search, filters, sort |
| `lib/models/` | Strongly-typed `PokemonEntry`, `PokemonForm`, `FilterOptions` |
| `lib/screens/list/` | Pokédex list view with adaptive layout and search header |
| `lib/screens/detail/` | Full species detail with stats, moves, evolution chain, and forms |
| `lib/widgets/` | Reusable `PokemonIcon`, `PokemonListTile`, form cards |
| `lib/core/constants/` | Type colors, move type mappings, UI constants |
| `scripts/` | Python data pipeline — download, scrape, extract, build |

## Roadmap

- [x] Search and multi-type filtering
- [x] Background isolate processing
- [x] Memoized evolution chains
- [x] Riverpod 3.0 migration
- [x] Adaptive responsive layouts
- [ ] Move DPS / damage calculations


---

Made with Flutter ❤️ for Pokémon GO trainers who want fast, accurate reference data without depending on an internet connection mid-raid.
