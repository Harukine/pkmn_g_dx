#!/usr/bin/env python3
import json
from pathlib import Path
from typing import Dict, List

def extract_move_stats():
    """Extract move stats from Game Master."""
    gm_path = Path('data/latest_game_master.json')
    if not gm_path.exists():
        print(f"Error: {gm_path} not found.")
        return {}

    with gm_path.open('r', encoding='utf-8') as f:
        game_master = json.load(f)

    # We need to look at both MOVE_SETTINGS (PvE) and COMBAT_MOVE (PvP)
    # For a general "Best Move", PvE stats are often a good baseline,
    # but we'll focus on MOVE_SETTINGS as it has duration/power.
    
    moves = {}
    
    for template in game_master:
        data = template.get('data', {})
        move_settings = data.get('moveSettings')
        
        if move_settings:
            move_id = str(move_settings.get('movementId', ''))
            if not move_id:
                continue
                
            # Basic stats
            power = float(move_settings.get('power', 0.0))
            duration_ms = int(move_settings.get('durationMs', 0))
            energy = abs(int(move_settings.get('energyDelta', 0)))
            pokemon_type = str(move_settings.get('pokemonType', '')).replace('POKEMON_TYPE_', '').title()
            
            # Identify if it's a fast move (usually has _FAST in ID or duration < 1.5s)
            is_fast = "_FAST" in move_id or duration_ms < 1500
            
            # Calculate DPS
            dps = 0.0
            if duration_ms > 0:
                dps = power / (duration_ms / 1000.0)
                
            # Calculate DPE for charged moves
            dpe = 0.0
            if not is_fast and energy > 0:
                dpe = power / energy
            
            moves[move_id] = {
                'id': move_id,
                'name': move_id.replace('_FAST', '').replace('_', ' ').title(),
                'type': pokemon_type,
                'power': power,
                'durationMs': duration_ms,
                'energy': energy,
                'dps': dps,
                'dpe': dpe,
                'isFast': is_fast,
                'score': dps * (dpe if dpe > 0 else 1.0)
            }

    print(f"Extracted {len(moves)} moves with stats")
    
    # Save for reference
    output_path = Path('data/move_stats.json')
    with output_path.open('w', encoding='utf-8') as f:
        json.dump(moves, f, indent=2, ensure_ascii=False)
        
    return moves

def find_best_moves(pokemon_types: List[str], available_moves: List[str], move_stats: Dict):
    """Find the best moves from a list based on stats and STAB."""
    if not available_moves:
        return None
        
    best_move = None
    best_score = -1.0
    
    for move_id in available_moves:
        stats = move_stats.get(move_id)
        if not stats:
            continue
            
        score = stats['score']
        
        # Apply STAB (Same Type Attack Bonus)
        if stats['type'] in pokemon_types:
            score *= 1.2
            
        if score > best_score:
            best_score = score
            best_move = move_id
            
    return best_move

if __name__ == "__main__":
    extract_move_stats()
