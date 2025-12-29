# Manuscript build system
# Generates main.docx and supplement.docx from markdown source

# Configuration
PANDOC = pandoc
SRC = manuscript.md
METADATA = metadata.yml
BUILD = build
REFDOC = --reference-doc=template.docx
CROSSREF = --filter pandoc-crossref
ZOTERO = --lua-filter=filters/zotero.lua
CITEPROC = --bibliography=references.bib --citeproc
MAIN = $(BUILD)/main.docx
SUPP = $(BUILD)/supplement.docx

.PHONY: all main supplement submission clean watch

# Default target: build both documents with live Zotero citations
all: main supplement

# Build main manuscript only
main: $(MAIN)

# Build supplement only
supplement: $(SUPP)

# Prepare files for journal submission (renamed figures/tables)
submission: main supplement
	python3 scripts/rename_for_submission.py

# Remove all build artifacts
clean:
	rm -rf $(BUILD)

# Watch mode: rebuild main document when files change
watch:
	@echo "Watching for changes... Press Ctrl+C to stop"
	@while true; do \
		make main; \
		sleep 2; \
	done

# Main document build rule
$(MAIN): $(SRC) $(METADATA)
	mkdir -p $(BUILD)
	$(PANDOC) $(METADATA) $(SRC) \
		--metadata=include-supplement:false \
		--lua-filter=filters/scholarly-metadata.lua \
		--lua-filter=filters/author-info-blocks.lua \
		--lua-filter=filters/table-docx-refs.lua \
		$(CROSSREF) \
		--lua-filter=filters/resolve-supp-refs.lua \
		$(ZOTERO) \
		--lua-filter=filters/split-main-supp.lua \
		$(REFDOC) -o $(MAIN)
	@echo "Main document built: $(MAIN)"

# Supplement build rule
$(SUPP): $(SRC) $(METADATA)
	mkdir -p $(BUILD)
	$(PANDOC) $(METADATA) $(SRC) \
		--metadata=include-main:false \
		--lua-filter=filters/scholarly-metadata.lua \
		--lua-filter=filters/author-info-blocks.lua \
		--lua-filter=filters/table-docx-refs.lua \
		$(CROSSREF) \
		--lua-filter=filters/supp-numbering.lua \
		--lua-filter=filters/resolve-supp-refs.lua \
		$(ZOTERO) \
		--lua-filter=filters/split-main-supp.lua \
		$(REFDOC) -o $(SUPP)
	@echo "Supplement built: $(SUPP)"
