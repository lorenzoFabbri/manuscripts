# Usage Guide

This guide provides detailed instructions for using the manuscript template.

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Writing Your Manuscript](#writing-your-manuscript)
4. [Managing Figures and Tables](#managing-figures-and-tables)
5. [Building Documents](#building-documents)
6. [Preparing for Submission](#preparing-for-submission)
7. [Customization](#customization)
8. [Troubleshooting](#troubleshooting)

## Installation

### Prerequisites

1. **Pandoc** (≥ 2.19):

   ```bash
   # macOS
   brew install pandoc

   # Ubuntu/Debian
   sudo apt install pandoc

   # Windows
   # Download from https://pandoc.org/installing.html
   ```

2. **Python** (≥ 3.7):

   ```bash
   python3 --version  # Check if installed
   ```

3. **PyYAML**:

   ```bash
   pip install pyyaml
   ```

4. **pandoc-crossref** (for cross-references):

   ```bash
   # macOS
   brew install pandoc-crossref

   # Others: download from https://github.com/lierdakil/pandoc-crossref/releases
   ```

### Optional: GitHub Actions

The template includes a `.github/workflows` configuration for automatic builds on push. To use:

1. Push to GitHub
2. GitHub Actions will automatically build PDFs/DOCX on each commit
3. Download artifacts from the Actions tab

## Quick Start

1. **Clone or download** this template
2. **Edit** `metadata.yml` with your paper details
3. **Write** your manuscript in `manuscript.md`
4. **Add figures** to `figures/`
5. **Add tables** to `tables/` and map in `tables.yml`
6. **Build**:
   ```bash
   make main        # Build main document
   make supplement  # Build supplementary materials
   make all         # Build both
   ```

## Writing Your Manuscript

### Document Structure

Your manuscript should follow this structure:

```markdown
# Introduction {#sec:intro}

Main text here...

# Methods {#sec:methods}

Methods content...

# Results {#sec:results}

Results...

# Discussion {#sec:discussion}

Discussion...

# Supplementary Material {#sec:supp}

Everything after this header goes into supplement.docx

## Supplementary Methods

Additional details...

# References {.unnumbered}

::: {#refs}
:::
```

**Important**: The `{#sec:supp}` identifier marks the split point between main and supplement.

### Cross-References

**Figures**:

```markdown
![Figure caption.](figures/figure1.png){#fig:label}

As shown in @fig:label, we observed...
```

**Tables (using placeholders)**:

```markdown
::: {#tbl:baseline}
Baseline characteristics
:::

See @tbl:baseline for details.
```

**Note**: Table divs are placeholders for cross-referencing. They can be placed anywhere in the document. Actual table files will be submitted separately.

**Sections**:

```markdown
# Methods {#sec:methods}

As described in @sec:methods, we used...
```

**Equations**:

```markdown
$$ y = mx + b $$ {#eq:linear}

Equation @eq:linear shows...
```

### Referencing Supplementary Items from Main Text

You can reference supplementary figures and tables from the main manuscript. They will automatically be numbered as \"Figure S1\", \"Table S1\", etc.

```markdown
# Results {#sec:results}

See @fig:supp1 and @tbl:sensitivity for additional details...

# Supplementary Material {#sec:supp}

![Supplementary analysis.](figures/figS1.png){#fig:supp1}

::: {#tbl:sensitivity}
Sensitivity analysis
:::
```

In main.docx: \"See Figure S1 and Table S1 for additional details...\"  
In supplement.docx: Both will be properly numbered and captioned.

### Citations

Use `@citationkey` for citations:

```markdown
Previous work [@Smith2024; @Jones2023] has shown...
```

Add references to `references.bib`:

```bibtex
@article{Smith2024,
  author = {Smith, John},
  title = {Example Article},
  journal = {Nature},
  year = {2024}
}
```

## Managing Figures and Tables

### Figures

**Placement flexibility**: Figures can be placed anywhere in the document - near their first reference, at the end of sections, or in a dedicated figures section. The system will correctly number and reference them regardless of placement.

```markdown
![Figure caption describing the content.](figures/figure1.png){#fig:label}
```

**For journal submission**: The `rename_for_submission.py` script will extract figure references and prepare them as separate files.

### Tables

**Table divs are placeholders** for cross-referencing only. They don't contain actual table content - just a caption for the reference system.

**Placement**: Table divs can be placed anywhere convenient:

- Near their first reference
- At the end of sections
- In a dedicated tables section
- Or grouped at the end of the document

The actual table content is submitted separately to journals.

**Example placeholder**:

```markdown
::: {#tbl:baseline}
Baseline characteristics of study participants
:::

As shown in @tbl:baseline, the groups were well-matched...
```

This produces: \"As shown in Table 1, the groups were well-matched...\"

#### Optional: Embedding Tables in Manuscript

For simple tables or draft versions, you can include Markdown tables:

```markdown
| Column 1 | Column 2 | Column 3 |
| -------- | -------- | -------- |
| Data 1   | Data 2   | Data 3   |

: Baseline characteristics {#tbl:baseline}
```

**Note**: Many journals require tables as separate files. The placeholder div approach keeps the manuscript cleaner and submission-ready.

## Building Documents

### Basic Commands

```bash
make main        # Build main.docx
make supplement  # Build supplement.docx
make all         # Build both
make clean       # Remove all build files
```

### Watch Mode

Automatically rebuild when files change:

```bash
make watch
```

Press Ctrl+C to stop.

### Manual Build

For custom builds:

```bash
pandoc metadata.yml manuscript.md \
  --lua-filter=filters/scholarly-metadata.lua \
  --lua-filter=filters/author-info-blocks.lua \
  --lua-filter=filters/table-docx-refs.lua \
  --lua-filter=filters/split-main-supp.lua \
  --filter pandoc-crossref \
  --reference-doc=template.docx \
  --citeproc \
  -o output.docx
```

## Preparing for Submission

### Understanding the Workflow

This template uses **placeholders** for figures and tables to maintain clean, readable manuscripts while supporting proper cross-referencing:

1. **During writing**: Figures are embedded in the markdown for preview; table divs are simple placeholders
2. **During build**: All cross-references are resolved correctly
3. **For submission**: Individual figure/table files are extracted and renamed separately

**Key insight**: Journals typically require:

- Main manuscript as a Word document (text only or with embedded figures)
- Figures as separate high-resolution files
- Tables as separate Word files

This template accommodates both embedded (for draft/review) and separate (for submission) workflows.

### Figure and Table Placement

**You have complete flexibility** in where you place figures and table divs:

✅ **Near first reference** (traditional):

```markdown
# Results

As shown in @fig:results, we observed...

![Results of experiment.](figures/fig2.png){#fig:results}
```

✅ **At end of section**:

```markdown
# Results

We observed three key findings (see @fig:results).

Additional analysis...

![Results of experiment.](figures/fig2.png){#fig:results}
```

✅ **Grouped at document end**:

```markdown
# Discussion

...end of text...

# Figures

![Figure 1.](figures/fig1.png){#fig:intro}
![Figure 2.](figures/fig2.png){#fig:results}

# Tables

::: {#tbl:baseline}
Baseline characteristics
:::

::: {#tbl:results}
Primary outcomes
:::
```

**The system will correctly number and reference items regardless of placement.**

### Step 1: Build Documents

```bash
make all
```

This creates:

- `build/main.docx` - Main manuscript
- `build/supplement.docx` - Supplementary materials

### Step 2: Rename for Submission (Optional)

```bash
make submission
```

This creates `build/submission/` with files renamed according to journal standards:

- `Fig1.png`, `Fig2.pdf`, ...
- `FigS1.png`, `FigS2.pdf`, ...
- `Table1.docx`, `Table2.docx`, ...
- `TableS1.docx`, `TableS2.docx`, ...

### Step 3: Submit

1. Upload `build/main.docx` as main manuscript
2. Upload `build/supplement.docx` as supplementary materials
3. Upload individual files from `build/submission/` as separate figures/tables

## Customization

### Word Template

Customize `template.docx` to match journal requirements:

1. Open `template.docx` in Word
2. Modify styles (Heading 1, Normal, etc.)
3. Adjust page layout, margins, fonts
4. Save and rebuild

### Citation Style

Change citation format by replacing `styles/nature.csl`:

1. Download style from [Zotero Style Repository](https://www.zotero.org/styles)
2. Save as `styles/yourjournal.csl`
3. Update `metadata.yml`:
   ```yaml
   csl: styles/yourjournal.csl
   ```

### Author Formatting

Modify `filters/author-info-blocks.lua` to change:

- Symbols for corresponding authors/equal contributors
- Affiliation numbering style
- Correspondence block format

## FAQ and Key Concepts

### Q: Do figures and tables need to be placed right after they are referenced?

**No.** You have complete flexibility:

- Place them near the reference (traditional)
- Place them at the end of sections
- Group all figures/tables at the document end
- Mix approaches as convenient

The cross-reference system works regardless of placement.

### Q: What are table divs and why are they empty?

Table divs like `:::  {#tbl:baseline}\nCaption\n:::` are **placeholders** for the cross-reference system. They:

- Provide a label (`tbl:baseline`) for references like `@tbl:baseline`
- Display a caption in the document
- Don't contain actual table content (submitted separately to journals)

This keeps your manuscript clean and submission-ready.

### Q: Can I reference supplementary items from the main text?

**Yes!** This is fully supported:

```markdown
# Results

See @fig:supp1 and @tbl:sensitivity for details...

# Supplementary Material {#sec:supp}

![Supp figure](figures/figS1.png){#fig:supp1}

::: {#tbl:sensitivity}
Sensitivity analysis
:::
```

The system automatically:

- Numbers them as "Figure S1", "Table S1"
- Resolves references in both main and supplement documents
- Maintains correct numbering even after the document is split

### Q: What happens during the build process?

1. **Pre-processing**: Author metadata is normalized
2. **Table numbering**: Table divs are numbered (Table 1, 2, ..., Table S1, S2, ...)
3. **Cross-reference resolution**: All `@fig:`, `@tbl:`, `@eq:` references are resolved across the FULL document
4. **Supplementary conversion**: References to supplementary items are converted to "Figure S1" format
5. **Citation processing**: Bibliography is generated
6. **Split**: Document is split into main.docx and supplement.docx

**Critical insight**: Steps 2-5 happen BEFORE the split, so references work across the boundary.

### Q: How do I add more supplementary figures/tables?

Simply add them after the `# Supplementary Material {#sec:supp}` header:

```markdown
# Supplementary Material {#sec:supp}

![First supp figure](figures/figS1.png){#fig:supp1}
![Second supp figure](figures/figS2.png){#fig:analysis}

::: {#tbl:sensitivity}
Sensitivity analysis
:::

::: {#tbl:additional}
Additional data
:::
```

They'll automatically be numbered S1, S2, S3, S4...
