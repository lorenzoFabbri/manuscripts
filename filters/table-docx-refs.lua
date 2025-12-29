--[[
table-docx-refs.lua – Handle table div references and numbering

This filter handles table divs (placeholders) used for cross-referencing. It:

1. Numbers main tables sequentially (Table 1, Table 2, ...)
2. Numbers supplementary tables (Table S1, Table S2, ...)
3. Adds "Table X." prefixes to main table div captions
4. Converts @tbl: citations to "Table X" or "Table SX" text
5. Prevents "Undefined cross-reference" warnings from pandoc-crossref

Usage:
    pandoc input.md --lua-filter=table-docx-refs.lua -o output.docx

Table divs in markdown should be formatted as:
    ::: {#tbl:label}
    Table caption text
    :::

Note: This filter must run BEFORE pandoc-crossref to intercept table
citations. Actual table content is submitted separately to journals.
--]] -- Track table references for DOCX-embedded tables
local table_counter = 0
local table_supp_counter = 0
local table_map = {}

-- Process document in order to correctly track main vs supplementary sections
function Pandoc(doc)
    local in_supp = false

    -- Walk blocks in order
    doc.blocks = doc.blocks:walk({
        Header = function(el)
            if el.identifier == "sec:supp" then in_supp = true end
            return el
        end,
        Div = function(el)
            if el.identifier and el.identifier:match("^tbl:") then
                if in_supp then
                    -- Supplementary table
                    table_supp_counter = table_supp_counter + 1
                    table_map[el.identifier] = "S" .. table_supp_counter
                    -- Don't add prefix here - let supp-numbering handle it
                else
                    -- Main table
                    table_counter = table_counter + 1
                    table_map[el.identifier] = tostring(table_counter)

                    -- Add "Table X." prefix to the content
                    local caption_text = pandoc.utils.stringify(el.content)
                    el.content = {
                        pandoc.Para({
                            pandoc.Strong({
                                pandoc.Str("Table " .. table_counter .. ".")
                            }), pandoc.Space(), pandoc.Str(caption_text)
                        })
                    }
                end
                return el

            elseif el.identifier and el.identifier:match("^tbls:") then
                -- Supplementary table with explicit tbls: prefix
                table_supp_counter = table_supp_counter + 1
                table_map[el.identifier] = "S" .. table_supp_counter
                return el
            end

            return el
        end
    })

    return doc
end

-- Replace @tbl: and @tbls: citations BEFORE pandoc-crossref sees them
-- This prevents the "Undefined cross-reference" warnings
function Cite(el)
    for _, citation in ipairs(el.citations) do
        if citation.id:match("^tbl:") and table_map[citation.id] then
            return pandoc.Str("Table " .. table_map[citation.id])
        elseif citation.id:match("^tbls:") and table_map[citation.id] then
            return pandoc.Str("Table " .. table_map[citation.id])
        end
    end
    return el
end

return {{Pandoc = Pandoc}, {Cite = Cite}}
