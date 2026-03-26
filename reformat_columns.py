#!/usr/bin/env python3
"""Reformat 2-column PDF-style text into single-column markdown."""

import re
import sys

def split_columns(line):
    """Split a line into (left, right) at the column boundary (15+ spaces)."""
    # Match: non-space content, then 15+ spaces, then optional non-space content
    m = re.match(r'^(.+?)(\s{15,})(.*)$', line)
    if m:
        left = m.group(1).rstrip()
        right = m.group(3).strip()
        return (left, right)
    # No clear split - if line is mostly spaces at start, treat as right column
    stripped = line.strip()
    if not stripped:
        return ('', '')
    if len(line) - len(line.lstrip()) > 40 and len(stripped) < 20 and stripped.isdigit():
        return ('', '')  # page number on right
    if line.startswith(' ') and len(line) - len(line.lstrip()) > 35:
        return ('', stripped)  # right column only
    return (stripped, '')

def is_page_number_line(line):
    """True if line is only optional whitespace and digits."""
    return bool(re.match(r'^\s*\d+\s*$', line))

def is_blank(line):
    return not line.strip()

def reformat(lines):
    # Split into pages by page-number lines
    pages = []
    current = []
    for line in lines:
        if is_page_number_line(line):
            if current:
                pages.append(current)
            current = []
        else:
            current.append(line)
    if current:
        pages.append(current)

    out = []
    for page in pages:
        left_lines = []
        right_lines = []
        for line in page:
            left, right = split_columns(line)
            if left:
                left_lines.append(left)
            if right and not (right.isdigit() and len(right) <= 3):
                right_lines.append(right)

        # Emit left column then right column
        if left_lines:
            out.extend(left_lines)
            out.append('')
        if right_lines:
            out.extend(right_lines)
            out.append('')

    # Post-process: format headers, collapse excessive blanks, remove stray page numbers
    result = []
    i = 0
    prev_blank = False
    while i < len(out):
        line = out[i]
        if is_page_number_line(line) or (line.strip().isdigit() and len(line.strip()) <= 3):
            i += 1
            continue
        if is_blank(line):
            if not prev_blank:
                result.append('')
            prev_blank = True
            i += 1
            continue
        prev_blank = False
        # Promote section headers to ## 
        stripped = line.strip()
        if re.match(r'^(Contents|Introduction|Disclaimer|Credits|Story Overview)\s*$', stripped, re.I):
            result.append('## ' + stripped)
        elif re.match(r'^Chapter \d+:', stripped):
            result.append('## ' + stripped)
        elif re.match(r'^Appendix [A-Z]', stripped):
            result.append('## ' + stripped)
        elif re.match(r'^(Epilogue|Appendix)\s', stripped):
            result.append('## ' + stripped)
        else:
            result.append(stripped)
        i += 1

    # Collapse multiple blank lines at end
    while result and result[-1] == '':
        result.pop()
    if result and result[-1] != '':
        result.append('')

    return '\n'.join(result)

def main():
    path = sys.argv[1] if len(sys.argv) > 1 else 'ADVENTURES/Pinewood.md'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.splitlines()
    output = reformat(lines)
    out_path = path + '.reformatted' if len(sys.argv) <= 1 else path
    with open(path, 'w', encoding='utf-8') as f:
        f.write(output)
    print('Reformatted', path)

if __name__ == '__main__':
    main()
