#!/usr/bin/env python3
import json
from pathlib import Path

STAB_MULTIPLIER = 1.2  # Reverted to standard Pokemon GO value
SUPER_EFFECTIVE_MULTIPLIER = 1.6 # Simulated bonus for best-case scenario ranking

def find_best_move(pokemon_types, move_ids, move_stats):
    if not move_ids:
        return None
        
    best_move = None
    best_score = -1.0
    
    for move_id in move_ids:
        move_id = str(move_id)
        # Handle case where move_id might have different suffix in stats
        stats = move_stats.get(move_id)
        if not stats:
            # Try without _FAST or with _FAST
            alt_id = move_id + "_FAST" if "_FAST" not in move_id else move_id.replace("_FAST", "")
            stats = move_stats.get(alt_id)
            
        if not stats:
            continue
            
        score = stats.get('score', 0)
        
        # Apply STAB (Same Type Attack Bonus)
        if stats.get('type') in pokemon_types:
            # User wants to also simulate a Super Effective bonus (1.6x) for STAB moves
            score *= (STAB_MULTIPLIER * SUPER_EFFECTIVE_MULTIPLIER)
            
        if score > best_score:
            best_score = score
            best_move = move_id
            
    return best_move

def enrich_pokedex_with_best_moves():
    pokedex_path = Path('data/pokemon_go_slim.json')
    stats_path = Path('data/move_stats.json')
    
    if not pokedex_path.exists() or not stats_path.exists():
        print("Required data files missing.")
        return

    with pokedex_path.open('r') as f:
        pokedex = json.load(f)
        
    with stats_path.open('r') as f:
        move_stats = json.load(f)

    for pokemon in pokedex:
        for form in pokemon.get('forms', []):
            types = form.get('types', [])
            
            # Quick Moves
            quick_moves = form.get('quickMoves', [])
            elite_quick = form.get('eliteQuickMoves', [])
            all_quick = list(dict.fromkeys(quick_moves + elite_quick))
            
            best_quick = find_best_move(types, all_quick, move_stats)
            form['bestQuickMove'] = best_quick
            
            # Cinematic Moves
            cinematic_moves = form.get('cinematicMoves', [])
            elite_cinematic = form.get('eliteCinematicMoves', [])
            all_cinematic = list(dict.fromkeys(cinematic_moves + elite_cinematic))
            
            best_cinematic = find_best_move(types, all_cinematic, move_stats)
            form['bestCinematicMove'] = best_cinematic

    with pokedex_path.open('w') as f:
        json.dump(pokedex, f, ensure_ascii=False, separators=(',', ':'))
        
    print(f"Enriched {len(pokedex)} Pokemon with best move data.")

if __name__ == "__main__":
    enrich_pokedex_with_best_moves()
