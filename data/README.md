# Pokémon GO Game Master Data Glossary

This directory contains the game data files for the Pokémon GO integration. Due to Niantic's use of internal codenames, certain fields in the `latest_game_master.json` may be ambiguous. This document serves as a reference for those terms and a structural overview of the data schema.

### Core Pokémon Data (`pokemonSettings`)

This section serves as the canonical reference for mapping Pokémon data from the Game Master. Use this template to identify the most useful fields for game logic, balancing, and UI.

#### Generic Pokémon Reference Mapping
```json
{
  "templateId": "V####_POKEMON_POKEMON_NAME",
  "data": {
    "pokemonSettings": {
      "pokemonId": "POKEMON_NAME",
      "type": "POKEMON_TYPE_1",
      "type2": "POKEMON_TYPE_2",
      "stats": {
        "baseStamina": "0-500",
        "baseAttack": "0-500",
        "baseDefense": "0-500"
      },
      "quickMoves": [ "MOVE_1_FAST", "MOVE_2_FAST" ],
      "cinematicMoves": [ "MOVE_1", "MOVE_2" ],
      "eliteQuickMove": [ "MOVE_1_FAST" ],
      "eliteCinematicMove": [ "MOVE_1" ],
      "evolutionBranch": [
        {
          "evolution": "TARGET_POKEMON_ID",
          "candyCost": "12-400",
          "evolutionItemRequirement": "ITEM_ID",
          "temporaryEvolution": "TEMP_EVOLUTION_NAME",
          "temporaryEvolutionEnergyCost": 200,
          "temporaryEvolutionEnergyCostSubsequent": 40
        }
      ],
      "familyId": "FAMILY_NAME",
      "kmBuddyDistance": "1-20",
      "shadow": {
        "purificationStardustNeeded": "1000-5000",
        "purificationCandyNeeded": "1-5",
        "purifiedChargeMove": "RETURN",
        "shadowChargeMove": "FRUSTRATION"
      },
      "tempEvoOverrides": [
        {
          "tempEvoId": "TEMP_EVOLUTION_NAME",
          "stats": { "baseStamina": "0-500", "baseAttack": "0-500", "baseDefense": "0-500" },
          "typeOverride1": "POKEMON_TYPE_1",
          "typeOverride2": "POKEMON_TYPE_2"
        }
      ],
      "breadTierGroup": "GROUP_1"
    }
  }
}
```

#### Field Reference Table

| Category | Field Name | Description |
| :--- | :--- | :--- |
| **Identity** | `pokemonId` | Canonical ID (e.g., `PIKACHU`). |
| | `form` | Specific form (e.g., `ALOLA`, `GALARIAN`, `MEGA`). |
| | `type` / `type2` | Elemental typing of the Pokémon. |
| | `familyId` | The evolution family group (e.g., `FAMILY_BULBASAUR`). |
| **Stats** | `stats` | Base `baseAttack`, `baseDefense`, and `baseStamina`. |
| **Moves** | `quickMoves` | Fast moves available via standard TMs. |
| | `cinematicMoves` | Charge moves available via standard TMs. |
| | `eliteQuickMove` | Fast moves requiring an Elite Fast TM. |
| | `eliteCinematicMove` | Charge moves requiring an Elite Charge TM. |
| **Evolution** | `parentPokemonId` | The pre-evolution form. |
| | `evolutionBranch` | Array of evolution paths, including costs (`candyCost`), items (`evolutionItemRequirement`), and buddy requirements. |
| | `thirdMove` | Costs (`stardustToUnlock`, `candyToUnlock`) for the second charge move. |
| **Special** | `shadow` | Purification costs and special moves (`RETURN`/`FRUSTRATION`). |
| | `tempEvoOverrides` | Stats and types for Mega/Primal forms. |
| | `breadTierGroup` | Internal codename for Dynamax tier (e.g., `GROUP_1`). |
| **Buddy** | `kmBuddyDistance` | Distance required to earn one candy. |
| | `buddySize` | Map visual size (e.g., `BUDDY_BIG`). |
| **Encounter** | `baseCaptureRate` | Base probability of a successful catch. |
| | `baseFleeRate` | Base probability of the Pokémon running away. |

### Move Data (`moveSettings` & `combatMove`)

Moves are split into two distinct systems: **Standard (PvE)** for Raids/Gyms and **Combat (PvP)** for Trainer Battles. Mapping both is essential for accurate gameplay simulation.

**Standard Move (PvE/Gyms):**
```json
{
  "templateId": "V####_MOVE_{{NAME}}",
  "data": {
    "moveSettings": {
      "movementId": "MOVE_NAME",
      "pokemonType": "POKEMON_TYPE_X",
      "power": "0-200",
      "durationMs": "500-5000",
      "damageWindowStartMs": "0-4000",
      "damageWindowEndMs": "0-5000",
      "energyDelta": "-100 to +20"
    }
  }
}
```

**Combat Move (PvP/GBL):**
```json
{
  "templateId": "COMBAT_V####_MOVE_{{NAME}}",
  "data": {
    "combatMove": {
      "uniqueId": "MOVE_NAME",
      "type": "POKEMON_TYPE_X",
      "power": "0-200",
      "energyDelta": "-100 to +20",
      "buffs": {
        "{{STAT}}StatStageChange": "-4 to +4",
        "buffActivationChance": "0.0-1.0",
        "targetDefenseStatStageChange": -1,
        "attackerAttackStatStageChange": 1
      }
    }
  }
}
```

---
*Note: These mappings are based on community datamining and pattern matching within the current Game Master structure. This document is intended for developer reference only.*
