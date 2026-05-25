import re
import json

files = [
    'apps/web/src/app/admin/finance/page.tsx',
    'apps/web/src/app/admin/settings/page.tsx',
    'apps/web/src/app/entrepreneur/dashboard/page.tsx',
    'apps/web/src/app/entrepreneur/earnings/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/new/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/review/page.tsx',
    'apps/web/src/app/investor/portfolio/page.tsx',
    'apps/web/src/components/DashboardLayout.tsx',
]

# Load en.ts to find existing translation values
with open('apps/web/src/i18n/locales/en.ts', 'r', encoding='utf-8') as f:
    en_content = f.read()

# Extract all existing English values from en.ts
existing_values = set()
for m in re.finditer(r':\s*"([^"]+)"', en_content):
    existing_values.add(m.group(1))

results = {}
for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    hardcoded = []
    for i, line in enumerate(lines, 1):
        # Skip imports, comments, classNames, variable names
        stripped = line.strip()
        if stripped.startswith('import ') or stripped.startswith('//') or stripped.startswith('*'):
            continue
        if 'className=' in stripped:
            # still check for text after className
            pass
            
        # Pattern 1: >Text< (JSX text content)
        for m in re.finditer(r'>([A-Z][a-zA-Z0-9 /\-\.\,\(\)\'&]+)<', line):
            text = m.group(1).strip()
            if len(text) > 1 and not text.startswith('{') and text not in ('React', 'ETB', 'FROM', 'TO', 'PDF', 'JPG', 'PNG', 'WEBP', 'SEPMS'):
                # Check if already using {t.xxx}
                if '{t.' not in text:
                    hardcoded.append((i, text, 'jsx_text'))
        
        # Pattern 2: >Text with newline (multi-line JSX)
        m = re.search(r'>\s*$', stripped)
        if m and i < len(lines):
            next_line = lines[i].strip() if i < len(lines) else ''
            if next_line and not next_line.startswith('<') and not next_line.startswith('{') and not next_line.startswith('//'):
                text = next_line.rstrip()
                if len(text) > 2 and text[0].isupper() and not text.startswith('ETB'):
                    hardcoded.append((i+1, text, 'jsx_text_newline'))
    
    if hardcoded:
        results[filepath] = hardcoded

for filepath, items in results.items():
    print(f"\n=== {filepath} ===")
    for line_no, text, ptype in items:
        already_in_en = text in existing_values
        marker = " [EXISTS]" if already_in_en else " [NEW]"
        print(f"  L{line_no}: {text}{marker}")

print(f"\nTotal files: {len(results)}")
total = sum(len(v) for v in results.values())
print(f"Total hardcoded strings: {total}")
