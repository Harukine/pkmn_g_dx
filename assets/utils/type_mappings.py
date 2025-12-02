"""Type name mapping utilities."""

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

def clean_type_name(raw_type: str) -> str:
    """Convert GAME_MASTER type to clean type name."""
    return TYPE_MAP.get(raw_type, 'Normal')

def clean_types(raw_types: list) -> list[str]:
    """Convert list of GAME_MASTER types to clean names."""
    return [clean_type_name(t) for t in raw_types]
