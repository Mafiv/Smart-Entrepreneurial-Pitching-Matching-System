import re

files_to_check = [
    'apps/web/src/app/entrepreneur/profile/page.tsx',
    'apps/web/src/app/investor/profile/page.tsx'
]

# Load en.ts to build reverse mapping
import ast

def load_translations():
    with open('apps/web/src/i18n/locales/en.ts', 'r', encoding='utf-8') as f:
        content = f.read()
    
    mapping = {}
    categories = re.findall(r'(\w+)\s*:\s*\{([^}]*)\}', content)
    for cat, body in categories:
        keys = re.findall(r'(\w+)\s*:\s*"([^"]+)"', body)
        for k, v in keys:
            mapping[v] = f"{{t.{cat}.{k}}}"
            
    return mapping

mapping = load_translations()

for filepath in files_to_check:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original = content
    
    def replacer(match):
        text = match.group(1).strip()
        if not text: return match.group(0)
        
        if text in mapping:
            return match.group(0).replace(text, mapping[text])
            
        return match.group(0)

    content = re.sub(r'>([^<]+)<', replacer, content)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

print("Done")
