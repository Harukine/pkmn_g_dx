"""Icon URL resolution for Pokemon GO assets."""
import requests
from pathlib import Path

GO_ICON_BASE = "https://raw.githubusercontent.com/PokeMiners/pogo_assets/master/Images/Pokemon/Addressable%20Assets/"

class IconResolver:
    """Resolves Pokemon icon URLs from PokeMiners repository."""
    
    def __init__(self, icon_cache: dict, session: requests.Session | None = None):
        """Initialize icon resolver.
        
        Args:
            icon_cache: Icon cache dictionary
            session: Optional requests session (creates new if None)
        """
        self.cache = icon_cache
        self.session = session or requests.Session()
        self.cache_dirty = False
    
    def resolve_base_icon(self, dex_number: int, manifest: dict | None = None, shiny: bool = False) -> str | None:
        """Resolve base Pokemon icon URL.
        
        Args:
            dex_number: Pokedex number
            manifest: Optional icon manifest for faster lookup
            shiny: Whether to get shiny variant
            
        Returns:
            Icon URL or None if not found
        """
        cache_type = "shiny_base" if shiny else "base"
        if cache_type not in self.cache:
            self.cache[cache_type] = {}
            
        if dex_number in self.cache[cache_type]:
            return self.cache[cache_type][dex_number]

        # First, check manifest if available
        if manifest and "base" in manifest:
            suffix = ".s.icon.png" if shiny else ".icon.png"
            for filename in manifest["base"]:
                if filename.startswith(f"pm{dex_number}.") and filename.endswith(suffix):
                    if not shiny and ".s.icon.png" in filename:
                        continue
                    url = f"{GO_ICON_BASE}{filename}"
                    self.cache[cache_type][dex_number] = url
                    self.cache_dirty = True
                    return url

        file_id = f"{dex_number:03d}"
        candidates = []
        if shiny:
            candidates.append(f"pm{dex_number}.s.icon.png")
        else:
            candidates.append(f"pm{dex_number}.icon.png")
            candidates.append(f"pokemon_icon_{file_id}_00.png")
            candidates.append(f"{file_id}.png")

        for filename in candidates:
            url = f"{GO_ICON_BASE}{filename}"
            try:
                resp = self.session.head(url, timeout=2)
                if resp.status_code == 200:
                    self.cache[cache_type][dex_number] = url
                    self.cache_dirty = True
                    return url
            except Exception:
                continue

        self.cache[cache_type][dex_number] = None
        self.cache_dirty = True
        return None

    def resolve_form_icon(
        self,
        dex_number: int,
        form_id: str,
        base_name: str | None = None,
        manifest: dict | None = None,
        shiny: bool = False
    ) -> str | None:
        """Resolve form-specific Pokemon icon URL.
        
        Args:
            dex_number: Pokedex number
            form_id: Form identifier (e.g., "MEGA", "ALOLA")
            base_name: Base Pokemon name for stripping
            manifest: Optional icon manifest
            shiny: Whether to get shiny variant
            
        Returns:
            Icon URL or None if not found
        """
        form_id_upper = str(form_id).upper()
        cache_key = f"{dex_number}:{form_id_upper}"
        
        cache_type = "shiny_form" if shiny else "form"
        if cache_type not in self.cache:
            self.cache[cache_type] = {}

        if cache_key in self.cache[cache_type]:
            return self.cache[cache_type][cache_key]
        
        # First, check manifest if available
        if manifest:
            lookup_keys = [
                f"{dex_number}:{form_id_upper}",
                f"{dex_number}:F{form_id_upper}",
                f"{dex_number}:C{form_id_upper}",
            ]
            
            if base_name:
                base_upper = str(base_name).upper()
                if form_id_upper.startswith(f"{base_upper}_"):
                    short_form = form_id_upper.replace(f"{base_upper}_", "")
                    lookup_keys.extend([
                        f"{dex_number}:{short_form}",
                        f"{dex_number}:F{short_form}",
                        f"{dex_number}:C{short_form}",
                    ])
            
            for manifest_key in lookup_keys:
                if manifest_key in manifest:
                    for filename in manifest[manifest_key]:
                        is_shiny_file = ".s.icon.png" in filename
                        if shiny != is_shiny_file:
                            continue
                        url = f"{GO_ICON_BASE}{filename}"
                        self.cache[cache_type][cache_key] = url
                        self.cache_dirty = True
                        return url
        
        suffix = ".s.icon.png" if shiny else ".icon.png"
        candidates = []
        
        # Try exact form_id
        candidates.append(f"pm{dex_number}.c{form_id}{suffix}")
        candidates.append(f"pm{dex_number}.f{form_id}{suffix}")
        candidates.append(f"pm{dex_number}.{form_id}{suffix}")

        # Try stripping base name
        if base_name:
            base_upper = str(base_name).upper()
            if form_id_upper.startswith(f"{base_upper}_"):
                short_form = form_id_upper.replace(f"{base_upper}_", "")
                candidates.append(f"pm{dex_number}.c{short_form}{suffix}")
                candidates.append(f"pm{dex_number}.f{short_form}{suffix}")
                candidates.append(f"pm{dex_number}.{short_form}{suffix}")
                
        for filename in candidates:
            url = f"{GO_ICON_BASE}{filename}"
            try:
                resp = self.session.head(url, timeout=2)
                if resp.status_code == 200:
                    self.cache[cache_type][cache_key] = url
                    self.cache_dirty = True
                    return url
            except Exception:
                pass
        
        self.cache[cache_type][cache_key] = None
        self.cache_dirty = True
        return None
