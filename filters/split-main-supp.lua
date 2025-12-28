--[[
split-main-supp.lua – Split document into main manuscript and supplementary sections

This filter enables separating a single markdown source into main and
supplementary documents by controlling which sections are included in the output.

The split point is determined by a header with id="sec:supp":
- Everything before this header is the main manuscript
- Everything from this header onwards is supplementary material

Control via metadata:
- include-supplement: false → outputs only main manuscript (default: true)
- include-main: false → outputs only supplementary material (default: true)

Usage in Makefile:
    # Build main document only
    pandoc --metadata=include-supplement:false ...
    
    # Build supplement only
    pandoc --metadata=include-main:false ...

Markdown structure:
    # Introduction
    Main manuscript content...
    
    # Supplementary Material {#sec:supp}
    Supplementary content...

Note: This filter must run after metadata processing filters to ensure
the metadata flags are properly set.
--]]

local in_supp = false
local include_supplement = true
local include_main = true

-- Extract metadata flags once at the beginning
function Meta(meta)
  if meta["include-supplement"] ~= nil then
    include_supplement = meta["include-supplement"]
  end
  if meta["include-main"] ~= nil then
    include_main = meta["include-main"]
  end
  return meta
end

function Header(el)
  if el.identifier == "sec:supp" then 
    in_supp = true 
  end
  
  if in_supp and not include_supplement then 
    return {} 
  end
  
  if (not in_supp) and not include_main then 
    return {} 
  end
  
  return el
end

function Block(el)
  if in_supp and not include_supplement then 
    return {} 
  end
  
  if (not in_supp) and not include_main then 
    return {} 
  end
  
  return el
end

-- Return filters in correct order: Meta must run first
return {
  { Meta = Meta },
  { Header = Header, Block = Block }
}
