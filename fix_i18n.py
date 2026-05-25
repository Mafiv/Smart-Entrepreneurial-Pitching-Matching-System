import os
import re

en_ts_path = 'apps/web/src/i18n/locales/en.ts'
with open(en_ts_path, 'r', encoding='utf-8') as f:
    content = f.read()

mapping = []
current_section = ''
for line in content.split('\n'):
    m_section = re.match(r'^\s+([a-zA-Z0-9_]+):\s*\{', line)
    if m_section:
        current_section = m_section.group(1)
        continue
    
    m_kv = re.search(r'^\s+([a-zA-Z0-9_]+):\s*"([^"]+)",', line)
    if m_kv and current_section:
        key = m_kv.group(1)
        val = m_kv.group(2)
        mapping.append({
            'val': val,
            'full_key': f't.{current_section}.{key}'
        })

# Sort mapping by length of value (longest first) to avoid partial replacements
mapping.sort(key=lambda x: len(x['val']), reverse=True)

print(f'Found {len(mapping)} keys in en.ts')

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

for file_path in files_to_update:
    with open(file_path, 'r', encoding='utf-8') as f:
        file_content = f.read()

    if 'useLanguage' not in file_content:
        if 'import { useAuth }' in file_content:
            file_content = file_content.replace('import { useAuth } from "@/context/AuthContext";', 'import { useAuth } from "@/context/AuthContext";\nimport { useLanguage } from "@/i18n/LanguageContext";')
            file_content = re.sub(r'(const \{[^}]*\}\s*=\s*useAuth\(\);?)', r'\1\n\tconst { t } = useLanguage();', file_content, count=1)
        else:
            # Maybe just components
            file_content = file_content.replace('import React', 'import { useLanguage } from "@/i18n/LanguageContext";\nimport React')

    for item in mapping:
        # Pattern 1: >Value<  --> >{t.section.key}<
        file_content = file_content.replace(f'>{item["val"]}<', f'>{{{item["full_key"]}}}<')
        # Pattern 2: "Value" --> {t.section.key} (usually in props like placeholder="Value")
        # Be careful not to replace things inside existing {} or already replaced keys.
        # But for now, simple replace:
        file_content = re.sub(r'(?<![=A-Za-z])"' + re.escape(item['val']) + r'"(?!\s*:)', f'{{{item["full_key"]}}}', file_content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(file_content)

print('Done')
