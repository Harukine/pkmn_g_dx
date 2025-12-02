#!/usr/bin/env python3
"""
Comprehensive icon scraper for Pokemon GO icons from PokeMiners.
Scrapes the GitHub web page to get ALL icon files, bypassing API rate limits.
"""
import re
import json
from pathlib import Path

def scrape_pokeminers_icons():
    """Scrape all icon filenames from PokeMiners GitHub page."""
    try:
        import requests
    except ImportError:
        print("Error: requests module not found")
        return None
    
    # Use GitHub API to get the full tree (bypasses 1000 file limit of web view)
    # We need to find the SHA for "Images/Pokemon/Addressable Assets" or just fetch the whole tree
    # Fetching the whole tree is easier:
    api_url = "https://api.github.com/repos/PokeMiners/pogo_assets/git/trees/master?recursive=1"
    print(f"Fetching file list from GitHub API: {api_url}...")
    
    try:
        response = requests.get(api_url, timeout=30)
        response.raise_for_status()
        data = response.json()
    except Exception as e:
        print(f"Failed to fetch from GitHub API: {e}")
        return None
    
    if 'truncated' in data and data['truncated']:
        print("WARNING: GitHub API response was truncated! We might miss files.")
        
    # Filter for icon files in the correct directory
    target_dir = "Images/Pokemon/Addressable Assets/"
    filenames = set()
    
    tree = data.get('tree', [])
    print(f"Scanned {len(tree)} files in repository...")
    
    for item in tree:
        path = item.get('path', '')
        if path.startswith(target_dir) and path.endswith('.icon.png'):
            # Extract just the filename
            filename = path.split('/')[-1]
            filenames.add(filename)
            
    print(f"Found {len(filenames)} icon files in target directory")
    
    # Parse into manifest structure
    manifest = {"base": []}
    
    for filename in sorted(filenames):
        dex, form_id, prefix, is_shiny = parse_icon_filename(filename)
        
        if "pm25.icon.png" in filename:
            print(f"DEBUG: Processing {filename} -> dex={dex}, form={form_id}, prefix={prefix}, shiny={is_shiny}")
        
        if dex is None:
            continue
        
        # Base icon
        if form_id is None:
            manifest["base"].append(filename)
            continue
        
        # Form icon - create lookup keys
        form_upper = form_id.upper()
        lookup_keys = [f"{dex}:{form_upper}"]
        
        if prefix:
            lookup_keys.append(f"{dex}:{prefix.upper()}{form_upper}")
        else:
            lookup_keys.append(f"{dex}:F{form_upper}")
            lookup_keys.append(f"{dex}:C{form_upper}")
        
        for key in lookup_keys:
            if key not in manifest:
                manifest[key] = []
            if filename not in manifest[key]:
                manifest[key].append(filename)
    
    return manifest


def parse_icon_filename(filename):
    """
    Parse icon filename to extract dex, form, and prefix.
    Handles suffixes like .s (shiny) and .g2 (gender variant).
    
    Returns: (dex, form_id, prefix, is_shiny)
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
    # We currently ignore the gender distinction for form grouping, 
    # but we need to strip it to get the form ID.
    if re.search(r"\.g\d+$", name):
        name = re.sub(r"\.g\d+$", "", name)
    
    # Now parse the core: pm{dex} or pm{dex}.{prefix}{form} or pm{dex}.{form}
    
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


def main():
    """Main entry point."""
    manifest = scrape_pokeminers_icons()
    
    if not manifest:
        print("Failed to scrape icons")
        return 1
    
    # Save to cache
    output_path = Path("data/icon_manifest.json")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w') as f:
        json.dump(manifest, f, indent=2, sort_keys=True)
    
    print(f"\nSaved manifest to {output_path}")
    print(f"Total manifest keys: {len(manifest)}")
    print(f"Base icons: {len(manifest.get('base', []))}")
    
    # Show some stats
    form_keys = [k for k in manifest.keys() if k != 'base']
    print(f"Form icon keys: {len(form_keys)}")
    
    # Show summary of form types
    print("\nIcon Summary:")
    mega_count = sum(1 for k in form_keys if 'MEGA' in k)
    costume_count = sum(1 for k in form_keys if k.startswith(('c', 'C')) or 'COSTUME' in k or '20' in k) # Rough heuristic
    
    print(f"  Mega/Primal forms: {mega_count}")
    print(f"  Potential costume/variant forms: {costume_count}")
    
    print("\nRandom sample of forms:")
    import random
    if form_keys:
        sample = random.sample(form_keys, min(10, len(form_keys)))
        for key in sorted(sample):
            print(f"  {key}: {manifest[key]}")
    
    return 0


if __name__ == "__main__":
    exit(main())
