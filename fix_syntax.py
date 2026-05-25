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
    
    # Fix showErrorToast(t.invitations.networkError}); -> showErrorToast(t.invitations.networkError);
    content = re.sub(r'showErrorToast\((t\.[a-zA-Z0-9_\.]+)\}\)', r'showErrorToast(\1)', content)
    # Fix || t.adminUsers.roleAdmin}; -> || t.adminUsers.roleAdmin;
    content = re.sub(r'\|\|\s*(t\.[a-zA-Z0-9_\.]+)\};', r'|| \1;', content)
    # Fix : t.dashboard.completeVerification}} -> : t.dashboard.completeVerification}
    content = re.sub(r':\s*(t\.[a-zA-Z0-9_\.]+)\}\}', r': \1}', content)
    # Fix title: t.nav.overview}, -> title: t.nav.overview,
    content = re.sub(r'title:\s*(t\.[a-zA-Z0-9_\.]+)\},', r'title: \1,', content)
    # Fix return t.nav.dashboard}; -> return t.nav.dashboard;
    content = re.sub(r'return\s+(t\.[a-zA-Z0-9_\.]+)\};', r'return \1;', content)
    # Fix join(", ") || data.message || t.pitchReview.submissionFailed}, -> || t.pitchReview.submissionFailed,
    content = re.sub(r'\|\|\s*(t\.[a-zA-Z0-9_\.]+)\},', r'|| \1,', content)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print('Syntax fixed')
