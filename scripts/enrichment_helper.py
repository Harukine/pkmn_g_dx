import json
from pathlib import Path
from typing import Dict, List, Optional

def load_pokemon_data(data_dir: Path) -> Dict[str, Dict]:
    path = data_dir / "pokemon_data.json"
    if not path.exists():
        return {}
    with open(path, 'r') as f:
        data = json.load(f)
        # Create lookup by exact id
        return {str(entry.get('id', '')): entry for entry in data}

def enrich_form(form_entry: Dict, rich_lookup: Dict[str, Dict]) -> Dict:
    pokemon_id = form_entry.get('pokemonId', '')
    base_id = pokemon_id.split('_')[0]
    
    rich = rich_lookup.get(pokemon_id) or rich_lookup.get(base_id)
    
    # Special case for Nidoran
    if not rich and (pokemon_id == 'NIDORAN' or base_id == 'NIDORAN'):
        rich = rich_lookup.get('NIDORAN_FEMALE')
        
    form_type = form_entry.get('formType')
    form_id = form_entry.get('formId')
    is_costume = form_entry.get('isCostume', False)

    # Handle replacement moves (bonus_cinematic_moves)
    # We check both the Game Master data (already in form_entry) and rich data
    bonus_cinematic_moves = []
    
    # 1. From Game Master
    entry_form_changes = form_entry.get('formChanges', [])
    for change in entry_form_changes:
        available_forms = change.get('availableForm', [])
        if form_id in available_forms or pokemon_id in available_forms:
            replacements = change.get('replacementMoves')
            if replacements:
                bonus_cinematic_moves.extend(replacements)

    # 2. From Rich Data
    if rich:
        rich_form_changes = rich.get('formChanges', [])
        for change in rich_form_changes:
            available_forms = change.get('availableForm', [])
            if form_id in available_forms or pokemon_id in available_forms:
                replacements = change.get('replacementMoves')
                if replacements:
                    bonus_cinematic_moves.extend(replacements)
                    
    # Early exit if no rich data
    if not rich:
        if bonus_cinematic_moves:
            base_moves = form_entry.get('cinematicMoves', [])
            form_entry['cinematicMoves'] = list(dict.fromkeys(base_moves + bonus_cinematic_moves))
            form_entry['reassignedMoves'] = bonus_cinematic_moves
        return form_entry
        
    # Extract fields from rich data
    shadow = rich.get('shadow')
    buddy = rich.get('buddy')
    mega_forms = rich.get('megaForms')
    moves = rich.get('moves')
    
    # Handle Mega overrides
    override_types = None
    override_attack = None
    override_defense = None
    override_stamina = None
    
    if (form_type == 'mega' or form_type == 'primal') and mega_forms:
        mega_data = None
        for m in mega_forms:
            m_form_id = m.get('formId', '')
            if m_form_id == form_id or (form_id and m_form_id in form_id):
                mega_data = m
                break
        
        if mega_data:
            if mega_data.get('types'):
                override_types = mega_data['types']
            stats = mega_data.get('stats')
            if stats:
                override_attack = stats.get('attack')
                override_defense = stats.get('defense')
                override_stamina = stats.get('stamina')
                
    if override_types:
        form_entry['types'] = override_types
    if override_attack is not None:
        form_entry['baseAttack'] = override_attack
    if override_defense is not None:
        form_entry['baseDefense'] = override_defense
    if override_stamina is not None:
        form_entry['baseStamina'] = override_stamina
        
    # Process enriched cinematic moves
    enriched_cinematic_moves = None
    if moves and rich.get('id') == pokemon_id and not is_costume:
        enriched_cinematic_moves = moves.get('charge', [])
        
    if bonus_cinematic_moves:
        base_moves = enriched_cinematic_moves if enriched_cinematic_moves is not None else form_entry.get('cinematicMoves', [])
        enriched_cinematic_moves = list(dict.fromkeys(base_moves + bonus_cinematic_moves))
        
    # Inject mapped data into the form entry
    form_entry['parentPokemonId'] = str(rich.get('parent')) if rich.get('parent') else None
    form_entry['shadowData'] = shadow
    form_entry['buddyDistance'] = buddy.get('kmDistance') if buddy else None
    form_entry['dynamaxTier'] = str(rich.get('dynamaxTier')) if rich.get('dynamaxTier') else None
    form_entry['megaForms'] = mega_forms
    form_entry['formChanges'] = rich.get('formChanges') or form_entry.get('formChanges')
    form_entry['reassignedMoves'] = bonus_cinematic_moves
    form_entry['pokemonClass'] = rich.get('pokemonClass') or form_entry.get('pokemonClass')
    form_entry['isTransferable'] = rich.get('isTransferable', True)
    form_entry['isTradable'] = rich.get('isTradable', True)
    
    evolutions = rich.get('evolutions')
    if evolutions:
        next_evos = []
        for e in evolutions:
            next_evos.append({
                'evolution': str(e.get('to', '')),
                'candyCost': e.get('candyCost', 0),
                'itemRequirement': str(e.get('itemRequirement')) if e.get('itemRequirement') else None,
            })
        if 'evolution' not in form_entry:
            form_entry['evolution'] = {}
        form_entry['evolution']['nextEvolutions'] = next_evos
        
    if moves and rich.get('id') == pokemon_id and not is_costume:
        form_entry['quickMoves'] = moves.get('fast', [])
    if enriched_cinematic_moves is not None:
        form_entry['cinematicMoves'] = enriched_cinematic_moves
        
    if moves:
        form_entry['eliteQuickMoves'] = moves.get('eliteFast', [])
        form_entry['eliteCinematicMoves'] = moves.get('eliteCharge', [])
        
    third_move = rich.get('thirdMove')
    if third_move:
        if 'evolution' not in form_entry:
            form_entry['evolution'] = {}
        form_entry['evolution']['thirdMoveStardust'] = third_move.get('stardustCost')
        form_entry['evolution']['thirdMoveCandy'] = third_move.get('candyCost')
        
    return form_entry
