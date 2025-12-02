"""Evolution data extraction from Game Master."""

def extract_temporary_evolutions(game_master: list) -> dict[str, list]:
    """Extract temporary evolutions (Mega/Primal) from Game Master.
    
    Args:
        game_master: List of Game Master templates
        
    Returns:
        Dictionary mapping base Pokemon ID to list of temp evolutions
    """
    temp_evolutions_map = {}
    
    for template in game_master:
        template_id = template.get("templateId", "")
        if not template_id.startswith("TEMPORARY_EVOLUTION_"):
            continue
        
        data = template.get("data", {})
        temp_evo_settings = data.get("temporaryEvolutionSettings", {})
        if not temp_evo_settings:
            continue
        
        temp_evo_id = temp_evo_settings.get("temporaryEvolutionId")
        pokemon_id = temp_evo_settings.get("pokemonId")
        
        if not temp_evo_id or not pokemon_id:
            continue
        
        # Extract the short form ID (e.g., "VENUSAUR_MEGA" -> "MEGA")
        temp_evo_upper = temp_evo_id.upper()
        pokemon_upper = pokemon_id.upper()
        
        short_evo_id = temp_evo_id
        if temp_evo_upper.startswith(f"{pokemon_upper}_"):
            short_evo_id = temp_evo_upper.replace(f"{pokemon_upper}_", "")
        
        # Get type if available
        temp_evo_type_raw = temp_evo_settings.get("type")
        
        evo_entry = {
            "evolutionId": pokemon_id,
            "formId": short_evo_id,
            "candyCost": None,
            "itemRequirement": None,
            "genderRequirement": None,
            "questRequirement": None,
            "temp_evo_id": temp_evo_id,
            "temp_evo_type": temp_evo_type_raw,
        }
        
        if pokemon_id not in temp_evolutions_map:
            temp_evolutions_map[pokemon_id] = []
        temp_evolutions_map[pokemon_id].append(evo_entry)
    
    return temp_evolutions_map
