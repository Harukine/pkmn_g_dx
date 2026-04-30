#!/usr/bin/env python3
"""
Generate Pokemon Data JSON
--------------------------
agency-data-engineer approach: Bronze → Silver → Gold

Bronze:  latest_game_master.json  (raw source, never touched)
Silver:  intermediate lookup dict (parsed, deduplicated per form)
Gold:    data/pokemon_data.json   (slim, readable, business-ready)

Fields included per entry:
  - Identity:   id, dexNumber, name, familyId
  - Typing:     types (list)
  - Stats:      attack, defense, stamina
  - Moves:      fast, charge, eliteFast, eliteCharge
  - Evolution:  parent, evolutions (with candyCost + itemRequirement)
  - Buddy:      kmBuddyDistance
  - ThirdMove:  thirdMoveCosts (stardust + candy)
  - Shadow:     shadow (purification costs + special moves)
  - Dynamax:    dynamaxTier
"""

import json
import re
from pathlib import Path

GAME_MASTER_PATH = Path("data/latest_game_master.json")
OUTPUT_PATH = Path("data/pokemon_data.json")

TYPE_PREFIX = "POKEMON_TYPE_"
FAMILY_PREFIX = "FAMILY_"


def clean_type(raw: str | None) -> str | None:
    if not raw:
        return None
    return raw.replace(TYPE_PREFIX, "").title()


def clean_family(raw: str | None) -> str | None:
    if not raw:
        return None
    return raw.replace(FAMILY_PREFIX, "")


def extract_dex(template_id: str) -> int | None:
    m = re.match(r"^V(\d{4})_POKEMON_", template_id)
    return int(m.group(1)) if m else None


def build_entry(dex: int, template_id: str, ps: dict) -> dict:
    """Map a single pokemonSettings block into a slim, useful dict."""

    # --- Identity ---
    pokemon_id = ps.get("pokemonId", "")
    form_id = ps.get("form", "")
    unique_id = form_id if form_id else pokemon_id
    
    family = clean_family(ps.get("familyId"))

    # --- Typing ---
    t1 = clean_type(ps.get("type"))
    t2 = clean_type(ps.get("type2"))
    types = [t for t in [t1, t2] if t]

    # --- Stats ---
    raw_stats = ps.get("stats", {})
    stats = {
        "attack": raw_stats.get("baseAttack"),
        "defense": raw_stats.get("baseDefense"),
        "stamina": raw_stats.get("baseStamina"),
    }

    # --- Moves ---
    moves = {
        "fast": ps.get("quickMoves", []),
        "charge": ps.get("cinematicMoves", []),
        "eliteFast": ps.get("eliteQuickMove", []),
        "eliteCharge": ps.get("eliteCinematicMove", []),
    }

    # --- Evolution ---
    parent = ps.get("parentPokemonId")
    evolution_branch = ps.get("evolutionBranch", [])
    evolutions = []
    for branch in evolution_branch:
        evo = branch.get("evolution")
        if not evo:
            # Could be a temporaryEvolution (Mega) — skip, handled in megaForms
            continue
            
        target_form = branch.get("form")
        evolve_to = target_form if target_form else evo
        
        evolutions.append({
            "to": evolve_to,
            "candyCost": branch.get("candyCost"),
            "itemRequirement": branch.get("evolutionItemRequirement"),
            "kmBuddyRequirement": branch.get("kmBuddyDistanceRequirement"),
            "mustBeBuddy": branch.get("mustBeBuddy", False),
            "genderRequirement": branch.get("genderRequirement"),
            "noCandyCostViaTrade": branch.get("noCandyCostViaTrade", False),
        })

    # --- Third Move ---
    third_move_raw = ps.get("thirdMove", {})
    third_move = None
    if third_move_raw:
        third_move = {
            "stardustCost": third_move_raw.get("stardustToUnlock"),
            "candyCost": third_move_raw.get("candyToUnlock"),
        }

    # --- Buddy ---
    km_buddy = ps.get("kmBuddyDistance")
    buddy_size = ps.get("buddySize")

    # --- Shadow ---
    shadow_raw = ps.get("shadow")
    shadow = None
    if shadow_raw:
        shadow = {
            "purificationStardust": shadow_raw.get("purificationStardustNeeded"),
            "purificationCandy": shadow_raw.get("purificationCandyNeeded"),
            "shadowChargeMove": shadow_raw.get("shadowChargeMove"),
            "purifiedChargeMove": shadow_raw.get("purifiedChargeMove"),
        }

    # --- Mega Forms ---
    mega_forms = []
    for evo in ps.get("tempEvoOverrides", []):
        evo_id = evo.get("tempEvoId", "").replace("TEMP_EVOLUTION_", "")
        evo_stats = evo.get("stats", {})
        t1_evo = clean_type(evo.get("typeOverride1")) or (types[0] if types else None)
        t2_evo = clean_type(evo.get("typeOverride2")) or (types[1] if len(types) > 1 else None)
        mega_forms.append({
            "formId": evo_id,
            "types": [t for t in [t1_evo, t2_evo] if t],
            "stats": {
                "attack": evo_stats.get("baseAttack"),
                "defense": evo_stats.get("baseDefense"),
                "stamina": evo_stats.get("baseStamina"),
            },
            "energyCost": None,  # Will be filled from evolutionBranch below
            "energyCostSubsequent": None,
        })

    # Fill mega energy costs from evolutionBranch temporaryEvolution entries
    for branch in evolution_branch:
        temp_evo = branch.get("temporaryEvolution")
        if not temp_evo:
            continue
        short_id = temp_evo.replace("TEMP_EVOLUTION_", "")
        for mf in mega_forms:
            if mf["formId"] == short_id:
                mf["energyCost"] = branch.get("temporaryEvolutionEnergyCost")
                mf["energyCostSubsequent"] = branch.get("temporaryEvolutionEnergyCostSubsequent")

    # --- Dynamax (BREAD) ---
    dynamax_tier = ps.get("breadTierGroup")

    # --- Transferability ---
    is_transferable = ps.get("isTransferable", True)
    is_tradable = ps.get("isTradable", True)

    return {
        "id": unique_id,
        "dexNumber": dex,
        "familyId": family,
        "types": types,
        "stats": stats,
        "moves": moves,
        "parent": parent,
        "evolutions": evolutions,
        "thirdMove": third_move,
        "buddy": {
            "kmDistance": km_buddy,
            "size": buddy_size,
        },
        "shadow": shadow,
        "megaForms": mega_forms if mega_forms else None,
        "dynamaxTier": dynamax_tier,
        "isTransferable": is_transferable,
        "isTradable": is_tradable,
    }


def main():
    print("Loading Game Master...")
    with open(GAME_MASTER_PATH, "r") as f:
        game_master = json.load(f)

    entries: list[dict] = []
    seen_ids: set[str] = set()

    for template in game_master:
        tid = template.get("templateId", "")
        if not re.match(r"^V\d{4}_POKEMON_", tid):
            continue
        # Skip internal copies / backfills
        if "COPY_" in tid or "BACKFILL" in tid:
            continue

        dex = extract_dex(tid)
        if dex is None:
            continue

        ps = template.get("data", {}).get("pokemonSettings")
        if not ps or not ps.get("stats"):
            continue

        pokemon_id = ps.get("pokemonId", "")
        form_id = ps.get("form", "")
        unique_id = form_id if form_id else pokemon_id
        
        if not unique_id or unique_id in seen_ids:
            continue
        seen_ids.add(unique_id)

        entry = build_entry(dex, tid, ps)
        entries.append(entry)

    # Sort by dex number, then by id
    entries.sort(key=lambda e: (e["dexNumber"], e["id"]))

    print(f"Extracted {len(entries)} Pokémon entries.")
    print(f"Writing to {OUTPUT_PATH}...")

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(entries, f, ensure_ascii=False, indent=2)

    # Quick stats
    with_shadow = sum(1 for e in entries if e["shadow"])
    with_mega = sum(1 for e in entries if e["megaForms"])
    with_dynamax = sum(1 for e in entries if e["dynamaxTier"])
    with_evolutions = sum(1 for e in entries if e["evolutions"])

    print(f"\n✅ Done!")
    print(f"   Total entries:      {len(entries)}")
    print(f"   With Shadow data:   {with_shadow}")
    print(f"   With Mega forms:    {with_mega}")
    print(f"   With Dynamax tier:  {with_dynamax}")
    print(f"   With evolutions:    {with_evolutions}")
    size_kb = OUTPUT_PATH.stat().st_size / 1024
    print(f"   Output size:        {size_kb:.1f} KB")


if __name__ == "__main__":
    main()
