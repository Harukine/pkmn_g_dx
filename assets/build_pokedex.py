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

# Add assets directory to path
ASSETS_DIR = Path(__file__).parent
sys.path.insert(0, str(ASSETS_DIR))

# Import the new extraction module
from pokemon_extractor import main as extract_main

def main():
    """Main entry point."""
    print("=" * 60)
    print("Building Pokedex Data")
    print("=" * 60)
    print()
    
    # Run the icon-first extraction
    extract_main()
    
    print()
    print("=" * 60)
    print("Pokedex data generation complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()
