# Pandoc Lua Filters

This directory contains Lua filters that process the manuscript during Pandoc conversion.

## Filter Overview

| Filter                   | Purpose                                            | Usage             |
| ------------------------ | -------------------------------------------------- | ----------------- |
| `scholarly-metadata.lua` | Normalizes author/affiliation metadata             | Main & Supplement |
| `author-info-blocks.lua` | Formats author/affiliation blocks                  | Main & Supplement |
| `table-docx-refs.lua`    | Handles table div references and numbering         | Main & Supplement |
| `resolve-supp-refs.lua`  | Converts supp fig/table refs to "Figure SX" format | Main & Supplement |
| `split-main-supp.lua`    | Splits document at `#sec:supp` header              | Main & Supplement |
| `supp-numbering.lua`     | Adds "Figure SX" prefixes to captions              | Supplement only   |

## Processing Pipeline

### Main Document Build

```
pandoc manuscript.md \
  --metadata=include-supplement:false \
  --lua-filter=filters/scholarly-metadata.lua \      # 1. Normalize metadata
  --lua-filter=filters/author-info-blocks.lua \      # 2. Format authors
  --lua-filter=filters/table-docx-refs.lua \         # 3. Number tables, handle refs
  --filter pandoc-crossref \                         # 4. Process fig/eq cross-refs
  --lua-filter=filters/resolve-supp-refs.lua \       # 5. Convert supp refs to "S" format
  --citeproc \                                       # 6. Process citations
  --lua-filter=filters/split-main-supp.lua \         # 7. Remove supplement section
  -o build/main.docx
```

### Supplement Build

```
pandoc manuscript.md \
  --metadata=include-main:false \
  --lua-filter=filters/supp-numbering.lua \          # 1. Add "Figure SX" caption prefixes
  --lua-filter=filters/scholarly-metadata.lua \      # 2. Normalize metadata
  --lua-filter=filters/author-info-blocks.lua \      # 3. Format authors
  --lua-filter=filters/table-docx-refs.lua \         # 4. Number tables, handle refs
  --filter pandoc-crossref \                         # 5. Process fig/eq cross-refs
  --lua-filter=filters/resolve-supp-refs.lua \       # 6. Convert supp refs to "S" format
  --citeproc \                                       # 7. Process citations
  --lua-filter=filters/split-main-supp.lua \         # 8. Remove main section
  -o build/supplement.docx
```

## Filter Details

### scholarly-metadata.lua

Processes author and affiliation metadata to ensure consistency:

- Converts various author/affiliation formats to normalized structure
- Resolves affiliation references (e.g., `ref: ucl` → full affiliation object)
- Assigns numeric indices to affiliations
- Merges affiliations defined in multiple places

**Input format** (in `metadata.yml`):

```yaml
author:
  - name: Jane Doe
    affiliations:
      - ref: ucl
    email: jane.doe@example.com
    corresponding: true

affiliations:
  - id: ucl
    name: University College London
```

### author-info-blocks.lua

Generates formatted author and affiliation blocks:

- Creates superscript affiliation numbers for each author
- Adds symbols for corresponding authors (✉) and equal contributors (\*)
- Formats affiliation list with numbers
- Generates correspondence block with email links

**Output format**:

```
Jane Doe¹'✉, John Smith²'*

¹ University College London
² Acme Corporation

✉ Correspondence: Jane Doe <jane.doe@example.com>
* These authors contributed equally to this work.
```

### split-main-supp.lua

Separates main manuscript from supplementary material:

- Tracks document sections via header IDs
- Uses `#sec:supp` as split point
- Respects `include-main` and `include-supplement` metadata flags
- Removes unwanted sections based on build target

**Manuscript structure**:

```markdown
# Introduction {#sec:intro}

Main content...

# Supplementary Material {#sec:supp}

Supplementary content...
```

### supp-numbering.lua

Adds "Figure SX" and "Table SX" prefixes to captions (supplement build only):

- Detects all figures and tables defined after `#sec:supp` header
- Adds bold "Figure SX." and "Table SX." prefixes to their captions
- Maintains separate counters for figures and tables

**Example**:

```markdown
# Supplementary Material {#sec:supp}

![Caption](figures/figS1.png){#fig:analysis}
```

→ Caption becomes: "**Figure S1.** Caption"

### table-docx-refs.lua

Handles table div references and numbering:

- Walks document in order to detect main vs supplementary sections
- Numbers main tables (Table 1, Table 2, ...)
- Numbers supplementary tables (Table S1, Table S2, ...)
- Adds "Table X." prefix to main table div captions
- Converts `@tbl:` citations to "Table X" or "Table SX" text
- Prevents "Undefined cross-reference" warnings from pandoc-crossref

**Usage**:

```markdown
::: {#tbl:baseline}
Baseline characteristics
:::

As shown in @tbl:baseline, we see...
```

→ "As shown in Table 1, we see..."

**Note**: Table divs are placeholders. The actual table content can be stored separately and submitted as individual files.

### resolve-supp-refs.lua

Converts supplementary figure/table references to \"Figure SX\" format:

- Runs AFTER pandoc-crossref processes the full document
- Catalogs all figures and tables defined after `#sec:supp` header
- Replaces pandoc-crossref links to supplementary items with plain \"Figure S1\", \"Table S1\" text
- Enables referencing supplementary items from the main manuscript

**How it works**:

```markdown
# Results {#sec:results}

See @fig:supp1 and @tbl:sensitivity...

# Supplementary Material {#sec:supp}

![Supp caption](figures/figS1.png){#fig:supp1}

::: {#tbl:sensitivity}
Sensitivity analysis
:::
```

In main document → \"See Figure S1 and Table S1...\"  
In supplement → Both caption and references show \"Figure S1\" and \"Table S1\"

## Filter Order Matters

The filter processing order is critical for correct operation:

1. **Supp-numbering first (supplement only)**: Must run before other filters to add caption prefixes to supplementary items

2. **Metadata filters early**: `scholarly-metadata.lua` → `author-info-blocks.lua` normalizes and formats author data

3. **Table-docx-refs before crossref**: Intercepts table citations and adds numbering so pandoc-crossref doesn't see them

4. **Pandoc-crossref middle**: Processes figure and equation cross-references after custom filters

5. **Resolve-supp-refs after crossref**: Replaces pandoc-crossref's output for supplementary items with custom \"SX\" numbering

6. **Citeproc before split**: Processes bibliography citations while full document is intact

7. **Split-main-supp runs last**: Removes unwanted sections (main or supplement) after all processing is complete

**Why this order?**

- Supplementary references must be resolved while the FULL document is available (before split)
- Custom filters that handle specific element types must run before general processors like pandoc-crossref
- The split happens last so all cross-references and citations can be resolved across the full document
