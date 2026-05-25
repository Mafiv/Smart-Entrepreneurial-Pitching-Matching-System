import json
import re

with open('new_translations.json', 'r', encoding='utf-8-sig') as f:
    translations = json.load(f)

def update_locale_file(filepath, lang_code):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Create replacement blocks
    for category, keys in translations.items():
        # Check if category exists
        cat_pattern = re.compile(rf'(\b{category}\s*:\s*{{)([^}}]*)(}})', re.DOTALL)
        match = cat_pattern.search(content)
        
        new_entries = []
        for key, vals in keys.items():
            val = vals[lang_code]
            # avoid escaping issue, assume vals don't have unescaped quotes for simplicity
            new_entries.append(f'\t\t{key}: "{val}",')
            
        new_entries_str = '\n'.join(new_entries)
        
        if match:
            # Category exists, append to it
            original_inner = match.group(2)
            # Find the last key, or just append before the closing brace
            new_inner = original_inner.rstrip()
            if not new_inner.endswith(',') and len(new_inner.strip()) > 0:
                new_inner += ','
            new_inner += '\n' + new_entries_str + '\n\t'
            
            content = content[:match.start(2)] + new_inner + content[match.start(3):]
        else:
            print(f"Warning: category {category} not found in {filepath}")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

update_locale_file('apps/web/src/i18n/locales/en.ts', 'en')
update_locale_file('apps/web/src/i18n/locales/am.ts', 'am')
print("Updated locale files")
