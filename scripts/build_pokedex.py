#!/usr/bin/env python3
"""
Main orchestrator for building the Pokedex data.

This script coordinates all data extraction steps:
1. Load Game Master
2. Extract Pokemon data
Main Pokedex Data Builder

This script orchestrates the data generation process:
1. Load Game Master data
2. Extract all Pokemon forms using icon-first approach
3. Save compiled data

The new icon-first approach ensures we capture all forms that have icons
in PokeMiners, including missing costume forms, Megas, and special variants.
"""

from pathlib import Path
import sys

# Add scripts directory to path
SCRIPTS_DIR = Path(__file__).parent
sys.path.insert(0, str(SCRIPTS_DIR))

# Import the extraction and generation modules
from pokemon_extractor import main as extract_main
from generate_pokemon_json import main as generate_main

def main():
    """Main entry point."""
    print("=" * 60)
    print("Building Pokedex Data")
    print("=" * 60)
    print()
    print("\n[1/2] Generating Mechanical Data (pokemon_data.json)...")
    generate_main()
    
    print("\n[2/4] Extracting Move Stats...")
    from extractors.move_stats_extractor import extract_move_stats
    extract_move_stats()

    print("\n[3/4] Running Icon-First Extraction (pokemon_go_slim.json)...")
    # Run the icon-first extraction
    extract_main()

    print("\n[4/4] Enriching with Best Moves...")
    from enrich_best_moves import enrich_pokedex_with_best_moves
    enrich_pokedex_with_best_moves()
    
    print()
    print("=" * 60)
    print("Pokedex data generation complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()
