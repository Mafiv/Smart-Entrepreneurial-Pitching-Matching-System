import re

file1 = 'apps/web/src/app/admin/settings/page.tsx'
with open(file1, 'r', encoding='utf-8') as f:
    c = f.read()
c = re.sub(r'\{\s*(t\.common\.confirm)\s*\}', r'\1', c)
with open(file1, 'w', encoding='utf-8') as f:
    f.write(c)

file2 = 'apps/web/src/app/entrepreneur/pitch/new/page.tsx'
with open(file2, 'r', encoding='utf-8') as f:
    c = f.read()
c = re.sub(r'new\s+Error\(\{\s*(t\.[a-zA-Z0-9_\.]+)\s*\}\)', r'new Error(\1)', c)
with open(file2, 'w', encoding='utf-8') as f:
    f.write(c)

print('Done')
