"""Game Master loading and parsing."""
import json
from pathlib import Path

def load_game_master(path: str | Path = 'data/latest_game_master.json') -> list:
    """Load and parse the Pokemon GO Game Master file.
    
    Args:
        path: Path to the Game Master JSON file
        
    Returns:
        Parsed Game Master data as a list of templates
        
    Raises:
        FileNotFoundError: If Game Master file doesn't exist
        json.JSONDecodeError: If file is not valid JSON
    """
    gm_path = Path(path)
    
    if not gm_path.exists():
        raise FileNotFoundError(f"Game Master file not found: {gm_path}")
    
    with gm_path.open('r', encoding='utf-8') as f:
        data = json.load(f)
    
    if not isinstance(data, list):
        raise ValueError("Game Master must be a list of templates")
    
    print(f"Loaded {len(data)} templates from Game Master")
    return data
