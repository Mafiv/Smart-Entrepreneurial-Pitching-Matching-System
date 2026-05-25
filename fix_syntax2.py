import re
files = [
    'apps/web/src/app/admin/finance/page.tsx',
    'apps/web/src/app/admin/settings/page.tsx',
    'apps/web/src/app/entrepreneur/dashboard/page.tsx',
    'apps/web/src/app/entrepreneur/earnings/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/new/page.tsx',
    'apps/web/src/app/entrepreneur/pitch/review/page.tsx',
    'apps/web/src/app/investor/portfolio/page.tsx',
    'apps/web/src/components/DashboardLayout.tsx'
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # showErrorToast({t.something});
    content = re.sub(r'showErrorToast\(\{*(t\.[a-zA-Z0-9_\.]+)\}\*\)', r'showErrorToast(\1)', content)
    # showSuccessToast({t.something});
    content = re.sub(r'showSuccessToast\(\{*(t\.[a-zA-Z0-9_\.]+)\}\*\)', r'showSuccessToast(\1)', content)
    
    content = re.sub(r'showErrorToast\(\{*(t\.[a-zA-Z0-9_\.]+)\}\)', r'showErrorToast(\1)', content)
    content = re.sub(r'showSuccessToast\(\{*(t\.[a-zA-Z0-9_\.]+)\}\)', r'showSuccessToast(\1)', content)

    # || {t.something},
    content = re.sub(r'\|\|\s*\{*(t\.[a-zA-Z0-9_\.]+)\}*,', r'|| \1,', content)

    # || {t.something} (no comma)
    content = re.sub(r'\|\|\s*\{(t\.[a-zA-Z0-9_\.]+)\}', r'|| \1', content)
    
    # === {t.something}
    content = re.sub(r'===\s*\{(t\.[a-zA-Z0-9_\.]+)\}', r'=== \1', content)

    # : {t.something}}
    content = re.sub(r':\s*\{(t\.[a-zA-Z0-9_\.]+)\}\}', r': \1}', content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print('Syntax fixed again')
