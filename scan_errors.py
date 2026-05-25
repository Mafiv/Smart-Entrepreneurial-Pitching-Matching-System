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

# Pattern: {t.xxx.yyy} used outside JSX (i.e., in JS expressions)
# We need to find all occurrences and report them
for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    for i, line in enumerate(lines, 1):
        # Find {t.xxx} that is NOT between > and < (i.e., not in JSX text position)
        # Heuristic: if the line has {t. but is NOT like >{t.xxx}< then it's suspicious
        matches = list(re.finditer(r'\{t\.[a-zA-Z0-9_.]+\}', line))
        for m in matches:
            start = m.start()
            # Check if preceded by > (JSX text context) - that's fine
            before = line[:start].rstrip()
            if before.endswith('>'):
                continue
            # Check if it's inside a JSX expression like {someCondition && {t.xxx}}
            # or a function call like showErrorToast({t.xxx})
            print(f'{file}:{i}: {line.rstrip()}')
            break

print('--- scan complete ---')
