--[[
resolve-supp-refs.lua – Replace pandoc-crossref output for supplementary items

This filter must run AFTER pandoc-crossref but BEFORE split-main-supp.lua.
It replaces pandoc-crossref's formatted references to supplementary items
with custom "Figure SX" / "Table SX" labels.

Process:
1. Catalog all items after sec:supp header
2. Number them sequentially as supplementary items  
3. Replace pandoc-crossref links to these items with "Figure S1", "Table S1" text

This allows referencing supplementary items from the main manuscript even though
they'll be removed during the split.
--]]

local supp_figs = {}
local supp_tbls = {}

-- First pass: catalog all supplementary items (those after sec:supp)
local function catalog(doc)
  local fig_count = 0
  local tbl_count = 0
  local currently_in_supp = false
  
  pandoc.walk_block(pandoc.Div(doc.blocks), {
    Header = function(el)
      if el.identifier == "sec:supp" then
        currently_in_supp = true
      end
    end,
    Figure = function(el)
      if currently_in_supp and el.identifier and el.identifier:match("^fig:") then
        fig_count = fig_count + 1
        supp_figs[el.identifier] = fig_count
      end
    end,
    Div = function(el)
      if currently_in_supp and el.identifier and el.identifier:match("^tbl:") then
        tbl_count = tbl_count + 1
        supp_tbls[el.identifier] = tbl_count
      end
    end
  })
end

-- Second pass: replace pandoc-crossref links
local function replace_link(el)
  -- pandoc-crossref creates links like [Figure 3](#fig:supp1)
  if el.target and el.target:match("^#") then
    local target_id = el.target:sub(2) -- remove the #
    
    -- Check if it's a supplementary figure
    if supp_figs[target_id] then
      return {pandoc.Str("Figure"), pandoc.Space(), pandoc.Str("S" .. supp_figs[target_id])}
    end
    
    -- Check if it's a supplementary table
    if supp_tbls[target_id] then
      return {pandoc.Str("Table"), pandoc.Space(), pandoc.Str("S" .. supp_tbls[target_id])}
    end
  end
  
  return el
end

-- Main filter function
return {
  {
    Pandoc = function(doc)
      -- Catalog all supplementary items
      catalog(doc)
      return doc
    end
  },
  {
    Link = replace_link
  }
}
