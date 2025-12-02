import json

def check_types(data):
    for entry in data:
        # Check base fields
        for field in ['baseAttack', 'baseDefense', 'baseStamina', 'dexNumber']:
            val = entry.get(field)
            if val is not None and not isinstance(val, (int, float)):
                print(f"Error in base {entry.get('basePokemonId')}: {field} is {type(val)} ({val})")

        # Check forms
        for form in entry.get('forms', []):
            for field in ['baseAttack', 'baseDefense', 'baseStamina', 'dexNumber']:
                val = form.get(field)
                if val is not None and not isinstance(val, (int, float)):
                    print(f"Error in form {form.get('pokemonId')} {form.get('formId')}: {field} is {type(val)} ({val})")
            
            # Check evolution
            evo_data = form.get('evolution', {})
            for field in ['thirdMoveStardust', 'thirdMoveCandy']:
                val = evo_data.get(field)
                if val is not None and not isinstance(val, (int, float)):
                    print(f"Error in form {form.get('pokemonId')} {form.get('formId')} evo: {field} is {type(val)} ({val})")
            
            for next_evo in evo_data.get('nextEvolutions', []):
                for field in ['candyCost', 'genderRequirement']:
                    val = next_evo.get(field)
                    if val is not None and not isinstance(val, (int, float)):
                        print(f"Error in form {form.get('pokemonId')} {form.get('formId')} nextEvo: {field} is {type(val)} ({val})")

try:
    with open('data/pokemon_go_slim.json', 'r') as f:
        data = json.load(f)
    check_types(data)
    print("Check complete.")
except Exception as e:
    print(f"Failed to load or parse: {e}")
