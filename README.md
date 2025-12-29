# Paper Template

Reproducible workflow for scientific writing using:

- **Markdown** for manuscript authoring
- **Pandoc** for format conversion
- **Word DOCX** templates for journal submission
- **Zotero** for live citations
- **Lua filters** for advanced processing (author affiliations, main/supplement splitting)

## Features

- ✅ Automatic author affiliation management with ORCID support
- ✅ Separate main manuscript and supplementary materials from single source
- ✅ **Cross-reference supplementary items from main text**
- ✅ Flexible figure/table placement (near reference, end of section, or grouped)
- ✅ Table placeholder system for clean manuscripts
- ✅ Automatic figure and table renaming for submission
- ✅ Custom Word template support

## Quick Start

1. **Add figures** to `figures/`
2. **Edit metadata** in `metadata.yml` (authors, affiliations, title)
3. **Write manuscript** in `manuscript.md` with table/figure placeholders
4. **Build outputs**:
   ```bash
   make main        # Build main document
   make supplement  # Build supplementary materials
   make submission  # Rename files for journal submission
   ```

## Directory Structure

```
manuscripts/
├── manuscript.md                # Main manuscript source (Markdown)
├── metadata.yml                 # Author/affiliation metadata, Pandoc settings
├── references.bib               # BibTeX bibliography
├── Makefile                     # Build automation
├── template.docx                # Word template for output formatting
├── figures/                     # All figure files (PNG, PDF, JPG)
├── tables/                      # Optional: pre-formatted tables (if not using placeholders)
│   └── tables.yml               # Optional: maps table IDs to DOCX files
├── filters/                     # Pandoc Lua filters for processing
│   ├── author-info-blocks.lua   # Format author/affiliation blocks
│   ├── scholarly-metadata.lua   # Normalize author metadata
│   ├── split-main-supp.lua      # Split main/supplement sections
│   ├── supp-numbering.lua       # Add "Figure SX" prefixes to captions
│   ├── table-docx-refs.lua      # Handle table div references
│   └── resolve-supp-refs.lua    # Convert supp refs to "SX" format
├── scripts/                     # Helper scripts
│   └── rename_for_submission.py # Rename files for journal submission
├── styles/                      # Citation styles
│   └── nature.csl               # Nature journal citation style
└── build/                       # Generated outputs (created by make)
    ├── main.docx
    ├── supplement.docx
    └── submission/              # Renamed files for submission
```

## Requirements

- Pandoc ≥ 2.19
- Python ≥ 3.7
- Make
- PyYAML (`pip install pyyaml`)

## Author Metadata

Authors and affiliations are managed in `metadata.yml` with support for:

- Multiple affiliations per author
- ORCID identifiers
- Corresponding and equal-contributor markers
- Email addresses

## Documentation

- **[USAGE.md](USAGE.md)** - Comprehensive usage guide with examples
- **[filters/README.md](filters/README.md)** - Detailed filter documentation and pipeline explanation

## License

MIT License - see LICENSE file for details
