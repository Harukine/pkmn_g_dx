#!/usr/bin/env python3
"""
Extract move types from Game Master and create a lookup JSON file.
"""

import json
from pathlib import Path

# Type mapping
TYPE_MAP = {
    'POKEMON_TYPE_NORMAL': 'Normal',
    'POKEMON_TYPE_FIGHTING': 'Fighting',
    'POKEMON_TYPE_FLYING': 'Flying',
    'POKEMON_TYPE_POISON': 'Poison',
    'POKEMON_TYPE_GROUND': 'Ground',
    'POKEMON_TYPE_ROCK': 'Rock',
    'POKEMON_TYPE_BUG': 'Bug',
    'POKEMON_TYPE_GHOST': 'Ghost',
    'POKEMON_TYPE_STEEL': 'Steel',
    'POKEMON_TYPE_FIRE': 'Fire',
    'POKEMON_TYPE_WATER': 'Water',
    'POKEMON_TYPE_GRASS': 'Grass',
    'POKEMON_TYPE_ELECTRIC': 'Electric',
    'POKEMON_TYPE_PSYCHIC': 'Psychic',
    'POKEMON_TYPE_ICE': 'Ice',
    'POKEMON_TYPE_DRAGON': 'Dragon',
    'POKEMON_TYPE_DARK': 'Dark',
    'POKEMON_TYPE_FAIRY': 'Fairy',
}

def extract_move_types():
    """Extract move types from Game Master."""
    gm_path = Path('data/latest_game_master.json')
    
    with gm_path.open('r', encoding='utf-8') as f:
        game_master = json.load(f)
    
    move_types = {}
    
    for template in game_master:
        template_id = template.get('templateId', '')
        
        # Check if this is a combat move
        if 'COMBAT_V' in template_id and '_MOVE_' in template_id:
            data = template.get('data', {})
            combat_move = data.get('combatMove', {})
            
            unique_id = combat_move.get('uniqueId')
            pokemon_type = combat_move.get('type')
            
            if unique_id and pokemon_type:
                # Map to clean type name
                clean_type = TYPE_MAP.get(pokemon_type, 'Normal')
                move_types[unique_id] = clean_type
                
                # Also add _FAST suffix variant (for quick moves)
                move_types[f"{unique_id}_FAST"] = clean_type
    
    print(f"Extracted {len(move_types)} move type mappings")
    
    # Write to JSON
    output_path = Path('data/move_types.json')
    with output_path.open('w', encoding='utf-8') as f:
        json.dump(move_types, f, indent=2, ensure_ascii=False)
    
    print(f"Wrote move types to {output_path}")
    
    return move_types

if __name__ == '__main__':
    extract_move_types()
