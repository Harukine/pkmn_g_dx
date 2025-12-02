"""Form metadata extraction and type determination."""

def is_costume_form(pokemon_id: str, form_id: str | None, form_name: str) -> bool:
    """Check if a form is a costume form based on keywords.
    
    Args:
        pokemon_id: Pokemon identifier
        form_id: Form identifier (may be None)
        form_name: Human-readable form name
        
    Returns:
        True if this appears to be a costume form
    """
    s = f"{pokemon_id}_{form_id or ''}_{form_name}".upper()

    keywords = [
        "FALL", "SPRING", "SUMMER", "WINTER",
        "HOLIDAY", "HALLOWEEN", "CHRISTMAS",
        "COSTUME", "ANNIV", "ANNIVERSARY",
        "PARTY", "SANTA", "FESTIVE",
        "FLOWER", "RIBBON", "HAT", "CAP",
        "LIMITED",
    ]
    if any(k in s for k in keywords):
        return True

    if any(year in s for year in [
        "2016", "2017", "2018", "2019",
        "2020", "2021", "2022", "2023", "2024", "2025"
    ]):
        return True

    return False


def determine_form_type(
    pokemon_id: str,
    form_id: str | None,
    form_name: str,
    metadata: dict | None = None,
    is_temp_evo: bool = False,
    temp_evo_type: str | None = None
) -> str:
    """Determine form type based on Game Master structure.
    
    Args:
        pokemon_id: Pokemon identifier
        form_id: Form identifier (may be None)
        form_name: Human-readable form name
        metadata: Optional form metadata from Game Master
        is_temp_evo: Whether this is a temporary evolution
        temp_evo_type: Type of temporary evolution
        
    Returns:
        One of: normal, regional, mega, primal, shadow, purified, costume, special
    """
    if metadata and metadata.get("isCostume"):
        return "costume"
    
    # Temporary evolutions (most reliable - from Game Master structure)
    if is_temp_evo and temp_evo_type:
        temp_upper = temp_evo_type.upper()
        if "MEGA" in temp_upper:
            return "mega"
        if "PRIMAL" in temp_upper:
            return "primal"
    
    # Check form_id for specific patterns
    if form_id:
        form_upper = str(form_id).upper()
        
        # Regional forms
        regional_keywords = ["ALOLA", "ALOLAN", "GALARIAN", "GALAR", "HISUIAN", "HISUI", "PALDEAN", "PALDEA"]
        if any(region in form_upper for region in regional_keywords):
            return "regional"
        
        # Shadow/Purified
        if "SHADOW" in form_upper:
            return "shadow"
        if "PURIFIED" in form_upper:
            return "purified"
        
        # Special forms (Clone, Armored, etc.)
        special_keywords = ["CLONE", "ARMORED", "COPY"]
        if any(special in form_upper for special in special_keywords):
            return "special"
    
    # Costume forms (keyword-based detection)
    if is_costume_form(pokemon_id, form_id, form_name):
        return "costume"
    
    # Default to normal
    return "normal"


def resolve_form_metadata(pokemon_id: str, game_master: list) -> dict | None:
    """Find form metadata for a Pokemon in Game Master.
    
    Args:
        pokemon_id: Pokemon identifier to look up
        game_master: List of Game Master templates
        
    Returns:
        Form metadata dictionary or None if not found
    """
    for template in game_master:
        data = template.get("data", {})
        form_settings = data.get("formSettings", {})
        if not form_settings:
            continue
        
        forms_array = form_settings.get("forms", [])
        for form_obj in forms_array:
            form_entry = form_obj.get("form")
            if form_entry == pokemon_id:
                return form_obj
    
    return None
