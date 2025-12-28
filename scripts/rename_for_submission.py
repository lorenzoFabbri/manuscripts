#!/usr/bin/env python3
"""Rename figures and tables for journal submission.

This script processes the manuscript.md file and:
1. Extracts all figure references from markdown image syntax
2. Extracts all table references from div identifiers
3. Copies figures and tables to build/submission/ with standardized names:
   - Main figures: Fig1.ext, Fig2.ext, ...
   - Supplementary figures: FigS1.ext, FigS2.ext, ...
   - Main tables: Table1.docx, Table2.docx, ...
   - Supplementary tables: TableS1.docx, TableS2.docx, ...

The script determines main vs. supplementary based on label prefixes:
- 'fig:' and 'tbl:' are main manuscript items
- 'figs:' and 'tbls:' are supplementary items

Usage:
    python3 scripts/rename_for_submission.py

Requirements:
    - PyYAML package (pip install pyyaml)
    - tables/tables.yml mapping file
    - manuscript.md source file
"""
import re
import shutil
import yaml
from pathlib import Path

MANUSCRIPT = Path("manuscript.md")
FIG_OUT = Path("build/submission")
TABLE_MAP = Path("tables/tables.yml")

FIG_OUT.mkdir(parents=True, exist_ok=True)

with open(TABLE_MAP) as f:
    table_map = yaml.safe_load(f)

fig = figS = tbl = tblS = 0

with MANUSCRIPT.open() as f:
    for line in f:
        # Match figures
        m = re.search(r'!\[.*?\]\((.*?)\)\{#(figs?:[^}]+)\}', line)
        if m:
            path, label = m.groups()
            src = Path(path)
            if label.startswith("figs:"):
                figS += 1
                dst = FIG_OUT / f"FigS{figS}{src.suffix}"
            else:
                fig += 1
                dst = FIG_OUT / f"Fig{fig}{src.suffix}"
            if src.exists():
                shutil.copy(src, dst)
                print(f"Copied: {src} -> {dst}")
        
        # Match tables
        m = re.search(r'\{#(tbls?:[^}]+)\}', line)
        if m:
            label = m.group(1)
            if label in table_map:
                src = Path(table_map[label])
                if label.startswith("tbls:"):
                    tblS += 1
                    dst = FIG_OUT / f"TableS{tblS}.docx"
                else:
                    tbl += 1
                    dst = FIG_OUT / f"Table{tbl}.docx"
                if src.exists():
                    shutil.copy(src, dst)
                    print(f"Copied: {src} -> {dst}")

print(f"\nSubmission files written to {FIG_OUT}/")
print(f"Main figures: {fig}, Supplementary figures: {figS}")
print(f"Main tables: {tbl}, Supplementary tables: {tblS}")
