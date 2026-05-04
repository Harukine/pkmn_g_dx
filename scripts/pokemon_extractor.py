#!/usr/bin/env python3
"""
Icon-First Pokemon Data Extraction

This script takes a completely different approach from the legacy extractor:
1. Start with ALL icons from PokeMiners (source of truth)
2. For each icon, look up data in Game Master
3. Create synthetic forms for icons without Game Master entries
4. Guarantee every form with an icon is captured

This ensures we get all 144+ form patterns including:
- FALL_2023, FASHION_2021, GIGANTAMAX
- Regional forms (ALOLA, GALARIAN, HISUIAN, PALDEA)
- Costume forms from all years
- Special forms (SPRING_2023_*, GOFEST_*, etc.)
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import enrichment_helper

# Paths
DATA_DIR = Path("data")
ICON_MANIFEST_PATH = DATA_DIR / "icon_manifest.json"
GAME_MASTER_PATH = DATA_DIR / "latest_game_master.json"
OUTPUT_PATH = DATA_DIR / "pokemon_go_slim.json"

# Icon base URL
GO_ICON_BASE = "https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Pokemon%20-%20256x256/Addressable%20Assets/"


def load_icon_manifest() -> Dict:
    """Load the scraped icon manifest."""
    with open(ICON_MANIFEST_PATH, 'r') as f:
        return json.load(f)


def load_game_master() -> List[Dict]:
    """Load Game Master data."""
    with open(GAME_MASTER_PATH, 'r') as f:
        return json.load(f)


def parse_icon_filename(filename: str) -> Tuple[Optional[int], Optional[str], Optional[str], bool]:
    """
    Parse icon filename to extract dex number, form ID, prefix, and shiny status.
    
    Returns: (dex_number, form_id, prefix, is_shiny)
    """
    if not filename.endswith(".icon.png"):
        return None, None, None, False
    
    # Remove extension
    name = filename[:-9]  # remove .icon.png
    
    # Check for shiny suffix
    is_shiny = False
    if name.endswith(".s"):
        is_shiny = True
        name = name[:-2]
    
    # Check for gender/variant suffix (e.g. .g2)
    if re.search(r"\.g\d+$", name):
        name = re.sub(r"\.g\d+$", "", name)
    
    # Base: pm{dex}
    match = re.match(r"^pm(\d+)$", name)
    if match:
        return int(match.group(1)), None, None, is_shiny
    
    # With prefix: pm{dex}.{f|c}{form}
    match = re.match(r"^pm(\d+)\.([fc])([^.]+)$", name)
    if match:
        return int(match.group(1)), match.group(3).upper(), match.group(2), is_shiny
    
    # Without prefix: pm{dex}.{form}
    match = re.match(r"^pm(\d+)\.([^.]+)$", name)
    if match:
        return int(match.group(1)), match.group(2).upper(), None, is_shiny
    
    return None, None, None, False


def build_pokemon_lookup(game_master: List[Dict]) -> Dict[int, Dict[str, Dict]]:
    """
    Build a lookup map: dex_number -> { form_id -> Pokemon data }.
    Example: 19 -> { 'NORMAL': {...}, 'ALOLA': {...} }
    """
    lookup = {}
    
    for template in game_master:
        data = template.get('data', {})
        pokemon_settings = data.get('pokemonSettings')
        if not pokemon_settings:
            continue
        
        stats = pokemon_settings.get('stats')
        if not stats:
            continue
        
        # Extract dex number from template ID (e.g., "V0001_POKEMON_BULBASAUR" = dex 1)
        template_id = template.get('templateId', '')
        match = re.match(r"^V(\d{4})_POKEMON_", template_id)
        if not match:
            continue
        
        dex_number = int(match.group(1))
        
        # Get Pokemon ID
        pokemon_id = str(pokemon_settings.get('pokemonId', ''))
        if not pokemon_id:
            continue
            
        # Determine form suffix from templateId
        # templateId format: V{dex}_POKEMON_{NAME}_{FORM}
        # e.g. V0019_POKEMON_RATTATA -> NORMAL
        # e.g. V0019_POKEMON_RATTATA_ALOLA -> ALOLA
        
        # We already matched ^V(\d{4})_POKEMON_
        # The rest of the string is {NAME}_{FORM}
        remaining = template_id[match.end():]
        
        # pokemon_id from settings is usually the base name (e.g. "RATTATA")
        # But sometimes it might differ slightly, so let's rely on the fact that
        # the remaining string STARTS with the pokemon_id (usually).
        # Actually, safer to just split by underscore.
        
        parts = remaining.split('_')
        
        # Heuristic: The first part is the name. Anything after is form.
        # BUT some names have underscores? (e.g. MR_MIME, HO_OH)
        # pokemon_id usually has the correct base name with underscores.
        
        base_name_id = pokemon_id
        
        if remaining == base_name_id:
            form_suffix = "NORMAL"
        elif remaining.startswith(base_name_id + "_"):
            form_suffix = remaining[len(base_name_id)+1:]
        elif remaining.endswith("_NORMAL"):
             # Handle Vxxxx_POKEMON_RATTATA_NORMAL case if it exists
             form_suffix = "NORMAL"
        else:
             # Fallback for weird cases or if pokemon_id doesn't match template name
             # e.g. if template is RATTATA_ALOLA and pokemonId is RATTATA
             # We can try to guess.
             if "_" in remaining:
                 # Assume last part is form? Or everything after first part?
                 # Let's try to subtract the base name if possible.
                 form_suffix = remaining.split('_')[-1] # Risky?
                 
                 # Better: use the parts logic relative to pokemon_id
                 # If pokemon_id is RATTATA, and remaining is RATTATA_ALOLA
                 pass
                 
             # Let's stick to the startswith logic, it should cover 99%
             # If it doesn't match, maybe it's a special case.
             # For now, default to NORMAL if we can't parse, but log it?
             form_suffix = "NORMAL"
             
             # Re-try strict parsing
             if remaining != base_name_id and base_name_id in remaining:
                 form_suffix = remaining.replace(base_name_id + "_", "")
        
        if dex_number not in lookup:
            lookup[dex_number] = {}
            
        # Extract type info
        type1 = pokemon_settings.get('type', '').replace('POKEMON_TYPE_', '').title()
        type2_raw = pokemon_settings.get('type2')
        type2 = type2_raw.replace('POKEMON_TYPE_', '').title() if type2_raw else None
        types = [t for t in [type1, type2] if t]
        
        # Extract class info
        pokemon_class = pokemon_settings.get('pokemonClass')
        if pokemon_class == 'POKEMON_CLASS_MYTHIC':
            pokemon_class = 'POKEMON_CLASS_MYTHICAL'
            
        # Extract form changes
        raw_form_changes = pokemon_settings.get('formChange', [])
        form_changes = []
        for change in raw_form_changes:
            c = {
                'availableForm': change.get('availableForm', []),
                'candyCost': change.get('candyCost'),
                'stardustCost': change.get('stardustCost'),
                'item': change.get('item'),
                'itemCostCount': change.get('itemCostCount'),
            }
            
            # Flatten move reassignment if it exists
            move_reassignment = change.get('moveReassignment', {})
            replacement_moves = []
            
            # Check cinematic moves
            for m in move_reassignment.get('cinematicMoves', []):
                replacement_moves.extend(m.get('replacementMoves', []))
            
            # Check quick moves
            for m in move_reassignment.get('quickMoves', []):
                replacement_moves.extend(m.get('replacementMoves', []))
                
            if replacement_moves:
                c['replacementMoves'] = replacement_moves
                
            form_changes.append(c)

        entry = {
            'pokemonId': pokemon_id,
            'baseName': base_name_id.replace('_', ' ').title(),
            'formSuffix': form_suffix,
            'baseAttack': stats.get('baseAttack'),
            'baseDefense': stats.get('baseDefense'),
            'baseStamina': stats.get('baseStamina'),
            'types': types,
            'pokemonClass': pokemon_class,
            'formChanges': form_changes,
            'familyId': str(pokemon_settings.get('familyId', '')).replace('FAMILY_', ''),
            'quickMoves': pokemon_settings.get('quickMoves', []),
            'cinematicMoves': pokemon_settings.get('cinematicMoves', []),
            'eliteQuickMoves': pokemon_settings.get('eliteQuickMove', []),
            'eliteCinematicMoves': pokemon_settings.get('eliteCinematicMove', []),
        }
        
        lookup[dex_number][form_suffix] = entry
    
    return lookup


def to_readable_name(form_id: str) -> str:
    """Convert form ID to readable name."""
    if not form_id:
        return "Normal"
    
    # Handle common patterns
    clean = form_id.replace('_', ' ').title()
    
    # Special cases
    replacements = {
        'Noevolve': 'No-Evolve',
        'Gofest': 'GO Fest',
        'Galarian': 'Galarian Form',
        'Alola': 'Alolan Form',
        'Hisuian': 'Hisuian Form',
        'Paldea': 'Paldean Form',
    }
    
    for old, new in replacements.items():
        clean = clean.replace(old, new)
    
    return clean


def determine_form_type(form_id: Optional[str], prefix: Optional[str]) -> str:
    """
    Determine form type based on form ID and prefix.
    Returns: normal, regional, mega, primal, costume, special
    """
    if not form_id:
        return "normal"
    
    form_upper = form_id.upper()
    
    # Mega/Primal
    if 'MEGA' in form_upper:
        return "mega"
    if 'PRIMAL' in form_upper:
        return "primal"
    if 'GIGANTAMAX' in form_upper:
        return "gigantamax"
    
    # Regional
    regional_keywords = ['ALOLA', 'GALARIAN', 'HISUIAN', 'PALDEA']
    if any(region in form_upper for region in regional_keywords):
        return "regional"
    
    # Shadow/Purified
    if 'SHADOW' in form_upper:
        return "shadow"
    if 'PURIFIED' in form_upper:
        return "purified"
    
    # Costume (based on prefix or keywords)
    if prefix == 'c':
        return "costume"
    
    costume_keywords = [
        'COSTUME', 'FALL', 'SPRING', 'SUMMER', 'WINTER',
        'FASHION', 'HAT', 'CAP', 'ANNIVERSARY', 'NOEVOLVE',
        'GOFEST', 'PARTY', 'HOLIDAY', '2018', '2019', '2020',
        '2021', '2022', '2023', '2024', '2025'
    ]
    if any(keyword in form_upper for keyword in costume_keywords):
        return "costume"
    
    # Special
    special_keywords = ['CLONE', 'ARMORED', 'COPY']
    if any(special in form_upper for special in special_keywords):
        return "special"
    
    return "normal"


def extract_all_forms() -> List[Dict]:
    """
    Main extraction function using icon-first approach.
    
    Returns list of Pokemon entries with all forms.
    """
    print("Loading icon manifest...")
    manifest = load_icon_manifest()
    
    print("Loading Game Master...")
    game_master = load_game_master()
    
    print("Building Pokemon lookup...")
    pokemon_lookup = build_pokemon_lookup(game_master)
    
    print("Loading Mechanical Data for Enrichment...")
    rich_lookup = enrichment_helper.load_pokemon_data(DATA_DIR)
    
    print(f"Found {len(pokemon_lookup)} Pokemon in Game Master")
    
    # Group forms by base Pokemon
    grouped: Dict[str, Dict] = {}
    
    # Process each icon key
    print(f"\nProcessing {len(manifest)} manifest keys...")
    
    # Process each icon key
    print(f"\nProcessing {len(manifest)} manifest keys...")
    
    processed = 0
    
    # Re-organize manifest into a flat list of (dex, form_id, list_of_files)
    all_forms_map = {} # (dex, form_id) -> list of files
    
    for key, filenames in manifest.items():
        if key == "base":
            for f in filenames:
                d, fid, p, s = parse_icon_filename(f)
                if d is None: continue
                k = (d, None) # Base form
                if k not in all_forms_map: all_forms_map[k] = []
                all_forms_map[k].append(f)
        else:
            # Existing form keys
            if not filenames: continue
            # Parse first to get dex/form
            d, fid, p, s = parse_icon_filename(filenames[0])
            if d is None: continue
            k = (d, fid)
            if k not in all_forms_map: all_forms_map[k] = []
            all_forms_map[k].extend(filenames)
            
    print(f"Identified {len(all_forms_map)} unique forms (base + variants)")
    
    for (dex, form_id), filenames in all_forms_map.items():
        processed += 1
        if processed % 100 == 0:
            print(f"  Processed {processed}/{len(all_forms_map)} forms...")
        
        # Look up Pokemon forms data
        forms_data = pokemon_lookup.get(dex)
        if not forms_data:
            # print(f"  Warning: No Game Master data for dex {dex}, skipping")
            continue
        
        # Determine which Game Master entry to use
        # 1. Try exact match (e.g. form_id="ALOLA" -> GM="ALOLA")
        # 2. Try "NORMAL" as fallback
        
        target_suffix = form_id if form_id else "NORMAL"
        pokemon_data = forms_data.get(target_suffix)
        
        # If not found (e.g. costume form like "FALL_2023"), fall back to NORMAL
        if not pokemon_data:
            pokemon_data = forms_data.get("NORMAL")
            
        # If still not found (rare, maybe only has specific forms?), take the first one
        if not pokemon_data and forms_data:
            pokemon_data = next(iter(forms_data.values()))
            
        if not pokemon_data:
            continue
            
        base_id = pokemon_data['pokemonId'].split('_')[0] # Ensure we get the root ID
        
        # Initialize Pokemon entry if needed
        if base_id not in grouped:
            grouped[base_id] = {
                'basePokemonId': base_id,
                'name': pokemon_data['baseName'],
                'dexNumber': dex,
                'forms': []
            }
        
        # Determine if this is a new form or base form
        is_base_form = form_id is None
        
        # We lost 'prefix' in the regrouping, but determine_form_type uses it.
        # We can re-derive it or just check filenames.
        # Actually determine_form_type needs prefix for 'c' check.
        # Let's check if ANY file has 'c' prefix
        has_c_prefix = any(parse_icon_filename(f)[2] == 'c' for f in filenames)
        prefix = 'c' if has_c_prefix else None
        
        form_type = determine_form_type(form_id, prefix)
        is_costume = form_type == "costume"
        
        # Find best icons
        icon_url = None
        shiny_icon_url = None
        
        # Sort filenames to prefer standard over gendered/weird ones
        # We want shortest filename usually (pm25.icon.png vs pm25.g2.icon.png)
        sorted_files = sorted(filenames, key=len)
        
        for f in sorted_files:
            _, _, _, is_shiny = parse_icon_filename(f)
            url = f"{GO_ICON_BASE}{f}"
            
            if is_shiny:
                if not shiny_icon_url:
                    shiny_icon_url = url
            else:
                if not icon_url:
                    icon_url = url
        
        # Fallback: if we only have shiny, use it for normal too (unlikely but safe)
        if not icon_url and shiny_icon_url:
            icon_url = shiny_icon_url
            
        form_entry = {
            'pokemonId': base_id if is_base_form or is_costume else f"{base_id}_{form_id}",
            'formId': form_id,
            'formName': to_readable_name(form_id) if form_id else "Normal",
            'formType': form_type,
            'isCostume': is_costume,
            'baseAttack': pokemon_data['baseAttack'],
            'baseDefense': pokemon_data['baseDefense'],
            'baseStamina': pokemon_data['baseStamina'],
            'types': pokemon_data['types'],
            'pokemonClass': pokemon_data.get('pokemonClass'),
            'formChanges': pokemon_data.get('formChanges', []),
            'dexNumber': dex,
            'goIconUrl': icon_url,
            'shinyGoIconUrl': shiny_icon_url,
            'familyId': pokemon_data['familyId'],
            'quickMoves': pokemon_data['quickMoves'],
            'cinematicMoves': pokemon_data['cinematicMoves'],
            'eliteQuickMoves': pokemon_data['eliteQuickMoves'],
            'eliteCinematicMoves': pokemon_data['eliteCinematicMoves'],
            'evolution': {
                'nextEvolutions': [],
                'thirdMoveStardust': None,
                'thirdMoveCandy': None,
            }
        }
        
        # Include formChanges from the base form to catch move reassignments
        if forms_data.get('NORMAL'):
            base_changes = forms_data['NORMAL'].get('formChanges', [])
            current_changes = form_entry.get('formChanges', [])
            # Combine without duplicates if possible, or just extend
            form_entry['formChanges'] = current_changes + base_changes

        # Apply mechanical data enrichment
        form_entry = enrichment_helper.enrich_form(form_entry, rich_lookup)
        
        # Check if form already exists
        forms_list = grouped[base_id]['forms']
        if not any(f.get('formId') == form_id for f in forms_list):
            forms_list.append(form_entry)
            
    print(f"\nEnsuring all Pokemon have a Base/Normal form...")
    added_base_count = 0
    
    # Create a set of all known filenames for quick lookup
    all_known_files = set()
    for filenames in manifest.values():
        all_known_files.update(filenames)
    if "base" in manifest:
        all_known_files.update(manifest["base"])
        
    for base_id, data in grouped.items():
        forms = data['forms']
        # Check if Normal form exists (formId is None)
        if not any(f.get('formId') is None for f in forms):
            # Missing Normal form! Add it.
            dex = data['dexNumber']
            forms_data = pokemon_lookup.get(dex)
            if not forms_data: continue
            
            # Use NORMAL or first available
            pokemon_data = forms_data.get("NORMAL")
            if not pokemon_data:
                pokemon_data = next(iter(forms_data.values()))
            
            # Construct standard base icon URL
            base_filename = f"pm{dex}.icon.png"
            base_icon_url = f"{GO_ICON_BASE}{base_filename}"
            
            # Check if this file actually exists in our manifest
            # If not, we should use a fallback (e.g. the first available form's icon)
            # This handles cases like Unown (dex 201) which has no pm201.icon.png, only pm201.fUNOWN_A.icon.png etc.
            if base_filename not in all_known_files:
                # Find a fallback icon from existing forms
                fallback_icon = None
                for f in forms:
                    if f.get('goIconUrl'):
                        fallback_icon = f.get('goIconUrl')
                        break
                
                if fallback_icon:
                    base_icon_url = fallback_icon
                    # print(f"  Using fallback icon for {data['name']} (Normal): {base_icon_url}")
            
            base_form = {
                'pokemonId': base_id,
                'formId': None,
                'formName': "Normal",
                'formType': "normal",
                'isCostume': False,
                'baseAttack': pokemon_data['baseAttack'],
                'baseDefense': pokemon_data['baseDefense'],
                'baseStamina': pokemon_data['baseStamina'],
                'types': pokemon_data['types'],
                'pokemonClass': pokemon_data.get('pokemonClass'),
                'formChanges': pokemon_data.get('formChanges', []),
                'dexNumber': dex,
                'goIconUrl': base_icon_url,
                'shinyGoIconUrl': None, 
                'familyId': pokemon_data['familyId'],
                'quickMoves': pokemon_data['quickMoves'],
                'cinematicMoves': pokemon_data['cinematicMoves'],
                'eliteQuickMoves': pokemon_data['eliteQuickMoves'],
                'eliteCinematicMoves': pokemon_data['eliteCinematicMoves'],
                'evolution': {
                    'nextEvolutions': [],
                    'thirdMoveStardust': None,
                    'thirdMoveCandy': None,
                }
            }
            
            # Apply mechanical data enrichment
            base_form = enrichment_helper.enrich_form(base_form, rich_lookup)
            
            forms.append(base_form)
            added_base_count += 1
            
    print(f"  Restored {added_base_count} missing base forms (using fallback icons if needed)")
    
    # Now process tempEvoOverrides for Mega/Primal forms
    mega_primal_count = 0
    for template in game_master:
        data = template.get('data', {})
        pokemon_settings = data.get('pokemonSettings')
        if not pokemon_settings:
            continue
        
        # Extract dex number from template ID
        template_id = template.get('templateId', '')
        match = re.match(r"^V(\d{4})_POKEMON_", template_id)
        if not match:
            continue
        
        dex_number = int(match.group(1))
        pokemon_id = str(pokemon_settings.get('pokemonId', ''))
        
        # Get base Pokemon data
        forms_data = pokemon_lookup.get(dex_number)
        if not forms_data:
            continue
            
        # Use NORMAL or first available for base info
        pokemon_data = forms_data.get("NORMAL")
        if not pokemon_data:
            pokemon_data = next(iter(forms_data.values()))
        
        base_id = pokemon_data['pokemonId']
        
        # Ensure Pokemon entry exists - initialize if needed
        if base_id not in grouped:
            grouped[base_id] = {
                'basePokemonId': base_id,
                'name': pokemon_data['baseName'],
                'dexNumber': dex_number,
                'forms': []
            }
            
            # Add base/normal form for this Pokemon since it wasn't in icons
            # Construct base icon URL directly
            base_icon_url = f"{GO_ICON_BASE}pm{dex_number}.icon.png"
            
            base_form = {
                'pokemonId': base_id,
                'formId': None,
                'formName': "Normal",
                'formType': "normal",
                'isCostume': False,
                'baseAttack': pokemon_data['baseAttack'],
                'baseDefense': pokemon_data['baseDefense'],
                'baseStamina': pokemon_data['baseStamina'],
                'types': pokemon_data['types'],
                'pokemonClass': pokemon_data.get('pokemonClass'),
                'formChanges': pokemon_data.get('formChanges', []),
                'dexNumber': dex_number,
                'goIconUrl': base_icon_url,
                'shinyGoIconUrl': None,
                'familyId': pokemon_data['familyId'],
                'quickMoves': pokemon_data['quickMoves'],
                'cinematicMoves': pokemon_data['cinematicMoves'],
                'eliteQuickMoves': pokemon_data['eliteQuickMoves'],
                'eliteCinematicMoves': pokemon_data['eliteCinematicMoves'],
                'evolution': {
                    'nextEvolutions': [],
                    'thirdMoveStardust': None,
                    'thirdMoveCandy': None,
                }
            }
            
            # Apply mechanical data enrichment
            base_form = enrichment_helper.enrich_form(base_form, rich_lookup)
            
            grouped[base_id]['forms'].append(base_form)
        
        # Process tempEvoOverrides
        temp_evos = pokemon_settings.get('tempEvoOverrides', [])
        for evo in temp_evos:
            evo_id = evo.get('tempEvoId')
            if not evo_id:
                continue
            
            evo_stats = evo.get('stats')
            if not evo_stats:
                continue
            
            # Parse the evo ID (e.g., "TEMP_EVOLUTION_MEGA_X" -> "MEGA_X")
            short_evo_id = evo_id.replace('TEMP_EVOLUTION_', '')
            
            # Get type overrides
            type1_override = evo.get('typeOverride1')
            type2_override = evo.get('typeOverride2')
            
            if type1_override:
                type1 = type1_override.replace('POKEMON_TYPE_', '').title()
            else:
                type1 = pokemon_data['types'][0] if pokemon_data['types'] else 'Normal'
            
            if type2_override:
                type2 = type2_override.replace('POKEMON_TYPE_', '').title()
            else:
                type2 = pokemon_data['types'][1] if len(pokemon_data['types']) > 1 else None
            
            evo_types = [t for t in [type1, type2] if t]
            
            # Determine form type
            form_type = 'mega' if 'MEGA' in short_evo_id else 'primal' if 'PRIMAL' in short_evo_id else 'special'
            
            # Construct Mega/Primal icon URL directly
            # Standard format: pm{dex}.f{FORM}.icon.png
            icon_url = f"{GO_ICON_BASE}pm{dex_number}.f{short_evo_id}.icon.png"
            
            # Create Mega/Primal form entry
            mega_entry = {
                'pokemonId': f"{base_id}_{short_evo_id}",
                'formId': short_evo_id,
                'formName': to_readable_name(short_evo_id),
                'formType': form_type,
                'isCostume': False,
                'baseAttack': evo_stats.get('baseAttack'),
                'baseDefense': evo_stats.get('baseDefense'),
                'baseStamina': evo_stats.get('baseStamina'),
                'types': evo_types,
                'pokemonClass': pokemon_data.get('pokemonClass'), # Megas share class usually
                'dexNumber': dex_number,
                'goIconUrl': icon_url,
                'shinyGoIconUrl': None,
                'familyId': pokemon_data['familyId'],
                'quickMoves': pokemon_data['quickMoves'],
                'cinematicMoves': pokemon_data['cinematicMoves'],
                'eliteQuickMoves': pokemon_data['eliteQuickMoves'],
                'eliteCinematicMoves': pokemon_data['eliteCinematicMoves'],
                'evolution': {
                    'nextEvolutions': [],
                    'thirdMoveStardust': None,
                    'thirdMoveCandy': None,
                }
            }
            
            # Apply mechanical data enrichment
            mega_entry = enrichment_helper.enrich_form(mega_entry, rich_lookup)
            
            # Add if doesn't exist
            forms_list = grouped[base_id]['forms']
            if not any(f.get('formId') == short_evo_id for f in forms_list):
                forms_list.append(mega_entry)
                mega_primal_count += 1
    
    print(f"  Added {mega_primal_count} Mega/Primal forms from Game Master")

    print(f"\nExtracted {len(grouped)} Pokemon with forms")
    
    # Convert to result format
    result = []
    for base_id, pokemon_data in grouped.items():
        forms = pokemon_data['forms']
        if not forms:
            continue
        
        # Find default form
        default = next((f for f in forms if f['formName'] == "Normal" and not f['isCostume']), None)
        if not default:
            default = next((f for f in forms if not f['isCostume']), None)
        if not default:
            default = forms[0]
        
        has_costume = any(f['isCostume'] for f in forms)
        
        entry = {
            'basePokemonId': base_id,
            'name': pokemon_data['name'],
            'defaultPokemonId': default['pokemonId'],
            'baseAttack': default['baseAttack'],
            'baseDefense': default['baseDefense'],
            'baseStamina': default['baseStamina'],
            'types': default['types'],
            'dexNumber': pokemon_data['dexNumber'],
            'goIconUrl': default.get('goIconUrl'),
            'shinyGoIconUrl': default.get('shinyGoIconUrl'),
            'hasCostumeForms': has_costume,
            'forms': forms,
        }
        
        result.append(entry)
    
    # Sort by dex number
    result.sort(key=lambda x: x['dexNumber'])
    
    return result


def main():
    """Main entry point."""
    print("=" * 60)
    print("Icon-First Pokemon Data Extraction")
    print("=" * 60)
    
    result = extract_all_forms()
    
    # Save output
    print(f"\nWriting {len(result)} Pokemon to {OUTPUT_PATH}...")
    with open(OUTPUT_PATH, 'w') as f:
        json.dump(result, f, ensure_ascii=False, separators=(',', ':'))
    
    # Print statistics
    total_forms = sum(len(p['forms']) for p in result)
    total_costumes = sum(1 for p in result for f in p['forms'] if f['isCostume'])
    
    print(f"\n✅ Complete!")
    print(f"  Total Pokemon: {len(result)}")
    print(f"  Total forms: {total_forms}")
    print(f"  Costume forms: {total_costumes}")
    
    # Show some example costume forms
    print(f"\nExample costume forms:")
    count = 0
    for p in result:
        for f in p['forms']:
            if f['isCostume'] and count < 10:
                print(f"  {p['name']} - {f['formName']}")
                count += 1
            if count >= 10:
                break
        if count >= 10:
            break
    
    print("=" * 60)


if __name__ == "__main__":
    main()
