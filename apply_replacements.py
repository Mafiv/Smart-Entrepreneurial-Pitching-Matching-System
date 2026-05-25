import json
import re

files_to_update = [
    'apps/web/src/app/admin/finance/page.tsx',
    'apps/web/src/app/admin/settings/page.tsx',
    'apps/web/src/app/entrepreneur/dashboard/page.tsx',
    'apps/web/src/app/entrepreneur/earnings/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/new/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/review/page.tsx',
    'apps/web/src/app/investor/portfolio/page.tsx',
    'apps/web/src/components/DashboardLayout.tsx'
]

with open('new_translations.json', 'r', encoding='utf-8-sig') as f:
    translations = json.load(f)

# Build a mapping from exact string to t.category.key
mapping = {}
for category, keys in translations.items():
    for key, vals in keys.items():
        mapping[vals['en']] = f"{{t.{category}.{key}}}"

for filepath in files_to_update:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original_content = content
    
    for exact_str, t_expr in mapping.items():
        # Only replace exact strings inside JSX tags >text<
        # We need to escape exact_str for regex
        escaped_str = re.escape(exact_str)
        # Regex to match > exact_str < with optional whitespace
        pattern = re.compile(r'>\s*' + escaped_str + r'\s*<')
        content = pattern.sub(f'>{t_expr}<', content)
        
        # Also handle cases where there's a trailing space like `>Text{" "}<`
        # Wait, if it has `{" "}`, the `>Text` might be isolated. Let's just do exact string replacement for `>{exact_str}`
        # It's safer to just replace any `> {exact_str} <` or `>{exact_str}<` or `>{exact_str} `
        
        # Another pattern: exact string that spans a line? That's harder.
        
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
            print(f"Updated {filepath}")
            
print("Done updating tsx files.")
