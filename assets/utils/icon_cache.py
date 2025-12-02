"""Icon cache management for faster builds."""
import json
from pathlib import Path

ICON_CACHE_PATH = Path('data/icons_cache.json')

def load_icon_cache() -> dict:
    """Load icon cache from disk.
    
    Returns:
        Dictionary with 'base', 'form', 'shiny_base', 'shiny_form' keys
    """
    if not ICON_CACHE_PATH.exists():
        return {"base": {}, "form": {}, "shiny_base": {}, "shiny_form": {}}
    
    try:
        raw = json.loads(ICON_CACHE_PATH.read_text(encoding="utf-8"))
        base = {int(k): v for k, v in raw.get("base", {}).items()}
        form = raw.get("form", {})
        shiny_base = {int(k): v for k, v in raw.get("shiny_base", {}).items()}
        shiny_form = raw.get("shiny_form", {})
        return {
            "base": base,
            "form": form,
            "shiny_base": shiny_base,
            "shiny_form": shiny_form
        }
    except Exception as exc:
        print(f"Warning: failed to read icon cache ({exc}), starting fresh.")
        return {"base": {}, "form": {}, "shiny_base": {}, "shiny_form": {}}

def save_icon_cache(cache: dict) -> None:
    """Save icon cache to disk.
    
    Args:
        cache: Icon cache dictionary with base/form/shiny_base/shiny_form keys
    """
    ICON_CACHE_PATH.write_text(
        json.dumps(
            {
                "base": {str(k): v for k, v in cache.get("base", {}).items()},
                "form": cache.get("form", {}),
                "shiny_base": {str(k): v for k, v in cache.get("shiny_base", {}).items()},
                "shiny_form": cache.get("shiny_form", {}),
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    print(f"Saved icon cache to {ICON_CACHE_PATH}")
