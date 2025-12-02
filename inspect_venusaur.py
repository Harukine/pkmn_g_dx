import json

try:
    with open('data/pokemon_go_slim.json', 'r') as f:
        data = json.load(f)
    
    venusaur = next((p for p in data if p['name'] == 'Venusaur'), None)
    if venusaur:
        print("Evolution Data:")
        print(json.dumps(venusaur['forms'][0]['evolution'], indent=2))
        print("\nForms Data:")
        for form in venusaur['forms']:
            print(f"Form ID: {form.get('formId')}, Name: {form.get('formName')}")
    else:
        print("Venusaur not found")

except Exception as e:
    print(f"Error: {e}")
