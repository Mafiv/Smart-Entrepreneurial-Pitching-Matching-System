import re

def remove_duplicates(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out = []
    seen_in_block = set()
    in_block = False
    
    for i, line in enumerate(lines):
        if re.match(r'^\s*[a-zA-Z0-9_]+\s*:\s*\{', line):
            in_block = True
            seen_in_block = set()
            out.append(line)
            continue
            
        if in_block and re.match(r'^\s*\},?', line):
            in_block = False
            out.append(line)
            continue
            
        if in_block:
            m = re.match(r'^\s*([a-zA-Z0-9_]+)\s*:', line)
            if m:
                key = m.group(1)
                if key in seen_in_block:
                    print(f"Removing duplicate '{key}' in {filepath}:{i+1}")
                    continue
                seen_in_block.add(key)
                
        out.append(line)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(out)

remove_duplicates('apps/web/src/i18n/locales/en.ts')
remove_duplicates('apps/web/src/i18n/locales/am.ts')
