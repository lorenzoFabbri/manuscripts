--[[
supp-numbering.lua – Add "Figure SX" and "Table SX" prefixes to supplementary items

This filter processes supplementary figures and tables defined after the
header with id="sec:supp". It:

1. Numbers supplementary figures sequentially (Figure S1, Figure S2, ...)
2. Numbers supplementary tables sequentially (Table S1, Table S2, ...)
3. Prefixes captions with bold "Figure SX." or "Table SX."

Usage:
    pandoc input.md --lua-filter=supp-numbering.lua -o output.docx

Note: This filter runs FIRST in the supplement build pipeline to add caption
prefixes before other filters process the document.

Supplementary items are those defined after the header with id="sec:supp".
--]] local figS, tblS = 0, 0

-- Process document in order to correctly track when we enter supp section
function Pandoc(doc)
    local in_supp = false

    -- Walk blocks in document order
    doc.blocks = doc.blocks:walk({
        Header = function(el)
            if el.identifier == "sec:supp" then in_supp = true end
            return el
        end,
        Figure = function(el)
            if in_supp and el.identifier and el.identifier:match("^fig:") then
                figS = figS + 1

                -- Extract the original caption text, stripping pandoc-crossref numbering
                local old_text = pandoc.utils.stringify(el.caption.long)
                -- Remove "Figure X: " prefix if pandoc-crossref added it
                old_text = old_text:gsub("^Figure %d+:%s*", "")

                el.caption.long = {
                    pandoc.Para({
                        pandoc.Strong(pandoc.Str("Figure S" .. figS .. ".")),
                        pandoc.Space(), pandoc.Str(old_text)
                    })
                }
            end
            return el
        end,
        Div = function(el)
            if in_supp and el.identifier and el.identifier:match("^tbl:") then
                tblS = tblS + 1

                local caption_text = pandoc.utils.stringify(el.content)
                -- Remove "Table X: " prefix if pandoc-crossref added it
                caption_text = caption_text:gsub("^Table %d+:%s*", "")

                el.content = {
                    pandoc.Para({
                        pandoc.Strong({pandoc.Str("Table S" .. tblS .. ".")}),
                        pandoc.Space(), pandoc.Str(caption_text)
                    })
                }
            end
            return el
        end
    })

    return doc
end
