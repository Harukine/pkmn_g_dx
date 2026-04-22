#!/usr/bin/env python3
"""
Downloads the latest Game Master from PokeMiners.
"""

import json
import urllib.request
from pathlib import Path

GAME_MASTER_URL = "https://raw.githubusercontent.com/PokeMiners/game_masters/master/latest/latest.json"

def download_game_master():
    print(f"Downloading latest Game Master from {GAME_MASTER_URL}...")
    
    # Ensure data directory exists
    data_dir = Path(__file__).parent.parent / "data"
    data_dir.mkdir(parents=True, exist_ok=True)
    
    output_path = data_dir / "latest_game_master.json"
    
    try:
        with urllib.request.urlopen(GAME_MASTER_URL) as response:
            data = response.read().decode('utf-8')
            # Parse to ensure it's valid JSON
            parsed_data = json.loads(data)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(parsed_data, f, indent=2)
                
        print(f"Successfully downloaded and saved to {output_path}")
    except Exception as e:
        print(f"Error downloading Game Master: {e}")
        raise

if __name__ == "__main__":
    download_game_master()
