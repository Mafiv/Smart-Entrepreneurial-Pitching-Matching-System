import json
import re

files_to_check = [
    'apps/web/src/app/admin/finance/page.tsx',
    'apps/web/src/app/admin/settings/page.tsx',
    'apps/web/src/app/entrepreneur/dashboard/page.tsx',
    'apps/web/src/app/entrepreneur/earnings/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/new/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/review/page.tsx',
    'apps/web/src/app/investor/portfolio/page.tsx',
    'apps/web/src/components/DashboardLayout.tsx'
]

# Load en.ts to build reverse mapping
import ast

def load_translations():
    with open('apps/web/src/i18n/locales/en.ts', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Simple regex to extract category: { key: "value" }
    mapping = {}
    categories = re.findall(r'(\w+)\s*:\s*\{([^}]*)\}', content)
    for cat, body in categories:
        keys = re.findall(r'(\w+)\s*:\s*"([^"]+)"', body)
        for k, v in keys:
            mapping[v] = f"{{t.{cat}.{k}}}"
            
    return mapping

mapping = load_translations()

# Add a few manual mappings for things that might have slight variations
manual_mapping = {
    "SEPMS": "{t.nav.dashboard}", # Just as a fallback or skip
    "Cancel": "{t.common.cancel}",
    "Done": "{t.common.save}",
    "Sign Out": "{t.common.signOut}",
    "Are you sure you want to sign out of your account?": "{t.common.signOutConfirm}"
}
mapping.update(manual_mapping)

for filepath in files_to_check:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original = content
    
    # Find >text< instances
    def replacer(match):
        text = match.group(1).strip()
        if not text: return match.group(0)
        
        # Exact match
        if text in mapping:
            # Reconstruct with the same whitespace
            return match.group(0).replace(text, mapping[text])
            
        return match.group(0)

    # Use regex to find text nodes in JSX
    # Match > followed by non-< characters, followed by <
    content = re.sub(r'>([^<]+)<', replacer, content)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

print("Done")
