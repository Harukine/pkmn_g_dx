import json
import re
import requests
from pathlib import Path

# URLs for PokeMiners GAME_MASTER
BASE_URL = "https://raw.githubusercontent.com/PokeMiners/game_masters/master/latest"
GM_URL = f"{BASE_URL}/latest.json"
TIMESTAMP_URL = f"{BASE_URL}/timestamp.txt"

# Pokémon GO icons (PokeMiners pogo_assets repo)
GO_ICON_BASE = (
    "https://raw.githubusercontent.com/"
    "PokeMiners/pogo_assets/master/Images/Pokemon/Addressable%20Assets/"
)

# Where to store raw + slim data locally
DATA_DIR = Path("data")
DATA_DIR.mkdir(exist_ok=True)

RAW_GM_PATH = DATA_DIR / "latest_game_master.json"
STAMP_PATH = DATA_DIR / "gm_timestamp.txt"
SLIM_PATH = DATA_DIR / "pokemon_go_slim.json"
ICON_CACHE_PATH = DATA_DIR / "icon_cache.json"

def _load_icon_cache() -> dict:
    if not ICON_CACHE_PATH.exists():
        return {"base": {}, "form": {}}
    try:
        raw = json.loads(ICON_CACHE_PATH.read_text(encoding="utf-8"))
        base = {int(k): v for k, v in raw.get("base", {}).items()}
        form = raw.get("form", {})
        return {"base": base, "form": form}
    except Exception as exc:
        print(f"Warning: failed to read icon cache ({exc}), starting fresh.")
        return {"base": {}, "form": {}}


ICON_CACHE = _load_icon_cache()
ICON_CACHE_DIRTY = False


def _persist_icon_cache() -> None:
    global ICON_CACHE_DIRTY
    if not ICON_CACHE_DIRTY:
        return
    ICON_CACHE_PATH.write_text(
        json.dumps(
            {
                "base": {str(k): v for k, v in ICON_CACHE["base"].items()},
                "form": ICON_CACHE["form"],
            },
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    ICON_CACHE_DIRTY = False


def download_if_new() -> bool:
    print("Checking remote timestamp...")
    resp = requests.get(TIMESTAMP_URL, timeout=10)
    resp.raise_for_status()
    remote_ts = resp.text.strip()

    local_ts = STAMP_PATH.read_text().strip() if STAMP_PATH.exists() else None

    if local_ts == remote_ts:
        print("No new GAME_MASTER. Using existing file.")
        return False

    print(f"New GAME_MASTER detected: {remote_ts} (was {local_ts})")
    gm_resp = requests.get(GM_URL, timeout=60)
    gm_resp.raise_for_status()

    RAW_GM_PATH.write_text(gm_resp.text, encoding="utf-8")
    STAMP_PATH.write_text(remote_ts, encoding="utf-8")
    print(f"Saved latest GAME_MASTER to {RAW_GM_PATH}")
    return True


def load_game_master() -> list[dict]:
    if not RAW_GM_PATH.exists():
        print("No local GAME_MASTER found, downloading...")
        gm_resp = requests.get(GM_URL, timeout=60)
        gm_resp.raise_for_status()
        RAW_GM_PATH.write_text(gm_resp.text, encoding="utf-8")

    with RAW_GM_PATH.open(encoding="utf-8") as f:
        data = json.load(f)

    if not isinstance(data, list):
        raise TypeError(f"Expected GAME_MASTER to be a list, got {type(data)}")

    return data


def to_readable_name(value) -> str:
    if value is None:
        return ""
    name = str(value)
    name = name.replace("POKEMON_", "").replace("POKEMON", "")
    name = name.replace("FORM_", "")
    name = name.replace("_", " ").title()
    return name.strip()


def type_from_field(field_value: str | None) -> str | None:
    if not field_value:
        return None
    if not field_value.startswith("POKEMON_TYPE_"):
        return field_value.title()
    base = field_value.replace("POKEMON_TYPE_", "")
    return base.title().replace("_", " ")


def split_base_and_form(pokemon_id_raw) -> tuple[str, str | None]:
    s = str(pokemon_id_raw)
    parts = s.split("_")
    if len(parts) == 1:
        return s, None
    base = parts[0]
    suffix = "_".join(parts[1:])
    return base, suffix


def is_costume_form(pokemon_id: str, form_id: str | None, form_name: str) -> bool:
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
    is_temp_evo: bool = False,
    temp_evo_type: str | None = None
) -> str:
    """
    Determine form type based on Game Master structure.
    
    Returns one of: normal, regional, mega, primal, shadow, purified, costume, special
    """
    
    # Temporary evolutions (most reliable - from Game Master structure)
    if is_temp_evo and temp_evo_type:
        temp_upper = temp_evo_type.upper()
        if "MEGA" in temp_upper:
            return "mega"
        if "PRIMAL" in temp_upper:
            return "primal"
    
    # Check form_id for specific patterns
    if form_id:
        form_upper = form_id.upper()
        
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



SESSION = requests.Session()

def resolve_go_icon_url(dex_number: int, session: requests.Session) -> str | None:
    """Try a few common filename patterns in the 256x256 icon folder."""
    global ICON_CACHE_DIRTY
    if dex_number in ICON_CACHE["base"]:
        return ICON_CACHE["base"][dex_number]

    file_id = f"{dex_number:03d}"

    candidates = [
        f"pm{dex_number}.icon.png",
        f"pm{dex_number}.s.icon.png", # shiny fallback?
        f"pokemon_icon_{file_id}_00.png", # legacy fallback
        f"{file_id}.png",
    ]

    for filename in candidates:
        url = f"{GO_ICON_BASE}{filename}"
        try:
            resp = session.head(url, timeout=2)
            if resp.status_code == 200:
                ICON_CACHE["base"][dex_number] = url
                ICON_CACHE_DIRTY = True
                return url
        except Exception:
            continue

    ICON_CACHE["base"][dex_number] = None
    ICON_CACHE_DIRTY = True
    return None


def resolve_form_icon_url(dex_number: int, form_id: str, session: requests.Session, base_name: str | None = None) -> str | None:
    """Try to find a Form/Costume icon in the Addressable Assets folder."""
    # form_id comes in as "MEGA_X", "PRIMAL", "COSTUME_2020", "ALOLA", "RATTATA_ALOLA" etc.
    global ICON_CACHE_DIRTY
    cache_key = f"{dex_number}:{form_id.upper()}"

    if cache_key in ICON_CACHE["form"]:
        return ICON_CACHE["form"][cache_key]
    
    candidates = []
    
    # 1. Try exact form_id
    candidates.append(f"pm{dex_number}.c{form_id}.icon.png")
    candidates.append(f"pm{dex_number}.f{form_id}.icon.png")
    candidates.append(f"pm{dex_number}.{form_id}.icon.png")

    # 2. Try stripping base name (e.g. RATTATA_ALOLA -> ALOLA)
    if base_name:
        base_upper = base_name.upper()
        if form_id.startswith(f"{base_upper}_"):
            short_form = form_id.replace(f"{base_upper}_", "")
            candidates.append(f"pm{dex_number}.c{short_form}.icon.png")
            candidates.append(f"pm{dex_number}.f{short_form}.icon.png")
            candidates.append(f"pm{dex_number}.{short_form}.icon.png")
            
    # 3. Try stripping "NORMAL" if present (e.g. PIKACHU_NORMAL -> NORMAL -> empty?)
    # Actually, usually we don't want icons for NORMAL if base icon works, but let's see.
    
    for filename in candidates:
        url = f"{GO_ICON_BASE}{filename}"
        try:
            resp = session.head(url, timeout=2)
            if resp.status_code == 200:
                ICON_CACHE["form"][cache_key] = url
                ICON_CACHE_DIRTY = True
                return url
        except Exception:
            pass
    
    ICON_CACHE["form"][cache_key] = None
    ICON_CACHE_DIRTY = True
    return None


def transform_game_master(gm_data: list[dict]) -> list[dict]:
    print(f"Found {len(gm_data)} templates in GAME_MASTER")

    # Create session for HTTP requests (icon validation)
    session = requests.Session()

    grouped: dict[str, dict] = {}

    for i, entry in enumerate(gm_data):
        if i % 1000 == 0:
            print(f"Scanning GM entries {i}/{len(gm_data)}...", end='\r')
        data = entry.get("data") or entry
        pokemon_settings = data.get("pokemonSettings")
        if not pokemon_settings:
            continue

        stats = pokemon_settings.get("stats")
        if not stats:
            continue

        pokemon_id_raw = pokemon_settings.get("pokemonId")
        if not pokemon_id_raw:
            continue

        base_attack = stats.get("baseAttack")
        base_defense = stats.get("baseDefense")
        base_stamina = stats.get("baseStamina")

        type1 = type_from_field(pokemon_settings.get("type"))
        type2 = type_from_field(pokemon_settings.get("type2"))
        types = [t for t in [type1, type2] if t]

        dex_number = pokemon_settings.get("pokedexNumber")

        # Fallback: extract from templateId (e.g. V0001_POKEMON_BULBASAUR)
        if not dex_number:
            template_id = entry.get("templateId") or data.get("templateId") or ""
            match = re.match(r"^V(\d{4})_POKEMON_", template_id)
            if match:
                dex_number = int(match.group(1))

        go_icon_url = None

        if isinstance(dex_number, int) and dex_number > 0:
            go_icon_url = resolve_go_icon_url(dex_number, session)

        base_id, suffix_form_id = split_base_and_form(pokemon_id_raw)
        explicit_form = pokemon_settings.get("form")
        explicit_form_name = to_readable_name(explicit_form) if explicit_form else None

        if suffix_form_id:
            form_id = suffix_form_id
            form_name = to_readable_name(suffix_form_id)
        elif explicit_form_name:
            form_id = str(explicit_form)
            form_name = explicit_form_name
        else:
            form_id = None
            form_name = "Normal"

        # Try to resolve specific icon for this form/costume
        if form_id and isinstance(dex_number, int) and dex_number > 0:
            specific_icon = resolve_form_icon_url(dex_number, form_id, session, base_id)
            if specific_icon:
                go_icon_url = specific_icon

        pokemon_id_str = str(pokemon_id_raw)
        is_costume = is_costume_form(pokemon_id_str, form_id, form_name)
        form_type = determine_form_type(pokemon_id_str, form_id, form_name)

        variant = {
            "pokemonId": pokemon_id_str,
            "formId": form_id,
            "formName": form_name,
            "formType": form_type,
            "isCostume": is_costume,
            "baseAttack": base_attack,
            "baseDefense": base_defense,
            "baseStamina": base_stamina,
            "types": types,
            "dexNumber": dex_number,
            "goIconUrl": go_icon_url,
        }

        base_key = str(base_id)
        if base_key not in grouped:
            grouped[base_key] = {
                "name": to_readable_name(base_id),
                "forms": [],
            }

        forms_list: list[dict] = grouped[base_key]["forms"]
        if not any(
                f["pokemonId"] == variant["pokemonId"] and f.get("formId") == variant["formId"]
                for f in forms_list
        ):
            forms_list.append(variant)

        # Process Mega/Primal forms (tempEvoOverrides) from pokemonSettings
        temp_evos = pokemon_settings.get("tempEvoOverrides")
        if temp_evos and isinstance(temp_evos, list):
            for evo in temp_evos:
                evo_id = evo.get("tempEvoId")
                if not evo_id:
                    continue

                evo_stats = evo.get("stats")
                if not evo_stats:
                    continue

                evo_type1 = type_from_field(evo.get("typeOverride1")) or type1
                evo_type2 = type_from_field(evo.get("typeOverride2")) or type2
                evo_types = [t for t in [evo_type1, evo_type2] if t]

                short_evo_id = evo_id.replace("TEMP_EVOLUTION_", "")
                evo_form_name = short_evo_id.replace("_", " ").title()

                # Try to find Pokemon GO icon for Mega/Primal forms
                evo_icon_url = None
                if isinstance(dex_number, int) and dex_number > 0:
                    # short_evo_id is like "MEGA", "MEGA_X", "PRIMAL"
                    # This matches the "fMEGA", "fMEGA_X", "fPRIMAL" naming in Addressable Assets
                    evo_icon_url = resolve_form_icon_url(dex_number, short_evo_id, session, base_id)

                # Determine form type based on temp evo ID
                evo_form_type = determine_form_type(
                    pokemon_id_str,
                    short_evo_id,
                    evo_form_name,
                    is_temp_evo=True,
                    temp_evo_type=evo_id
                )

                evo_variant = {
                    "pokemonId": pokemon_id_str,
                    "formId": short_evo_id,
                    "formName": evo_form_name,
                    "formType": evo_form_type,
                    "isCostume": False,
                    "baseAttack": evo_stats.get("baseAttack"),
                    "baseDefense": evo_stats.get("baseDefense"),
                    "baseStamina": evo_stats.get("baseStamina"),
                    "types": evo_types,
                    "dexNumber": dex_number,
                    "goIconUrl": evo_icon_url,
                }

                if not any(
                    f["pokemonId"] == evo_variant["pokemonId"] and f.get("formId") == evo_variant["formId"]
                    for f in forms_list
                ):
                    forms_list.append(evo_variant)




    result: list[dict] = []

    for i, (base_id, info) in enumerate(grouped.items()):
        if i % 50 == 0:
            print(f"Processing {i}/{len(grouped)}: {info['name']}")
        forms: list[dict] = info["forms"]

        normal_id = f"{base_id}_NORMAL"
        has_normal_entry = any(f["pokemonId"] == normal_id for f in forms)
        if has_normal_entry:
            forms = [
                f for f in forms
                if not (f["pokemonId"] == base_id and (f["formName"] or "").lower() == "normal")
            ]

        info["forms"] = forms
        if not forms:
            continue

        default = next(
            (
                f for f in forms
                if (f["formName"] or "").lower() == "normal" and not f["isCostume"]
            ),
            None,
        )
        if default is None:
            default = next((f for f in forms if not f["isCostume"]), None)
        if default is None:
            default = forms[0]

        has_costume = any(f["isCostume"] for f in forms)
        default_go_icon = default.get("goIconUrl")
        default_dex = default.get("dexNumber")

        entry_dict = {
            "basePokemonId": base_id,
            "name": info["name"],
            "defaultPokemonId": default["pokemonId"],
            "baseAttack": default["baseAttack"],
            "baseDefense": default["baseDefense"],
            "baseStamina": default["baseStamina"],
            "types": default["types"],
            "dexNumber": default_dex,
            "goIconUrl": default_go_icon,
            "hasCostumeForms": has_costume,
            "forms": forms,
        }

        result.append(entry_dict)

    print(f"Extracted {len(result)} grouped Pokémon entries")
    return result


def main():
    download_if_new()
    if not RAW_GM_PATH.exists():
        print("No GAME_MASTER file present, exiting.")
        return

    gm_data = load_game_master()
    slim_list = transform_game_master(gm_data)

    SLIM_PATH.write_text(
        json.dumps(slim_list, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    print(f"Wrote slim Pokémon data to {SLIM_PATH.resolve()}")
    _persist_icon_cache()


if __name__ == "__main__":
    main()