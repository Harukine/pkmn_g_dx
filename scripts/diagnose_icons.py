import re
import requests
from pokemon_extractor import parse_icon_filename

def diagnose():
    url = "https://github.com/PokeMiners/pogo_assets/tree/master/Images/Pokemon%20-%20256x256/Addressable%20Assets"
    print(f"Scraping {url}...")
    
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
    except Exception as e:
        print(f"Failed to fetch: {e}")
        return

    # Broad regex
    pattern = r'(pm[a-zA-Z0-9_.]+\.icon\.png)'
    filenames = set(re.findall(pattern, response.text))
    print(f"Found {len(filenames)} total files.")

    unparsed = []
    parsed_weird = []
    
    for f in filenames:
        dex, form, prefix = parse_icon_filename(f)
        
        if dex is None:
            unparsed.append(f)
        elif form is None and prefix is None:
            # Base icon, normal
            pass
        elif form is None and prefix == 's':
            # Shiny base, normal
            pass
        else:
            # Form
            pass
            
        # Check for potential issues
        if form and '.' in form:
            parsed_weird.append((f, dex, form, prefix))

    print(f"\nUnparsed files ({len(unparsed)}):")
    for f in unparsed:
        print(f"  {f}")

    print(f"\nFiles with dots in form ID ({len(parsed_weird)}):")
    for f, d, fo, p in parsed_weird:
        print(f"  {f} -> Dex: {d}, Form: {fo}, Prefix: {p}")

if __name__ == "__main__":
    diagnose()
