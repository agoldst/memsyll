--[[
    memsyll-cite.lua: run citeproc, modify output for better web-ready markdown
    Andrew Goldstone, 2026

    This filter simply creates hyperlinked citations where bibliography entries
    have URLs, which CSL alone cannot do.

    N.B. the output format on the command line must be explicitly -citations,
    otherwise citeproc is no-op.

    See citeproc.sh for example usage.

    TODO fix bad handling of multicites like [@cite1, @cite2]
]]

local logging = require "logging"

-- table of ids of references to add links to
local to_link = { }

-- link-adder, called below after to_link has been populated
local function add_links(cite)
    -- check if the citation is on our list of cites with URLs
    local linked = cite.citations:find_if(
        function (v)
            return to_link[v.id]
        end
    )
    -- if so, make the citation a hyperlink
    if linked then
        return pandoc.Cite(
            pandoc.Link(cite.content, to_link[linked.id]),
            cite.citations
        )
    else
        return cite
    end
end

-- cleanup CSL's mess when it comes to closing punctuation
-- by looking for periods following a citation closing with a period or comma
-- and removing them. It's not elegant but I think it works okay

local quote = lpeg.S("\"'”’") -- curly & straight
local close_punct = lpeg.S(",.") * quote^0 * -1 -- [,.]["'”’]*$
local cleanup_pat = (1 - close_punct)^0 * close_punct -- complete pattern

local function cleanup_postcite (il)
    for i = #il, 1, -1 do
        if il[i].t == "Cite" and il[i + 1] then
            if cleanup_pat:match(pandoc.utils.stringify(il[i])) and
                il[i + 1].t == "Str" and
                close_punct:match(il[i + 1].text) then
                il:remove(i + 1)
            end
        end
    end

    return il
end

function Pandoc(doc)
    -- verify output format option
    if PANDOC_WRITER_OPTIONS.extensions:find("citations") then
        io.stderr:write("Error: Output format must have citations disabled,")
        io.stderr:write("e.g. pandoc -t markdown-citations\n")
        return nil
    end


    local refs = pandoc.utils.references(doc)
    for ref in refs:iter() do
        if ref.url then
            -- remember which refs have URLs
            to_link[ref.id] = ref.url
        end
    end

    -- call citeproc so we can then munge the results
    local citeproc_result = pandoc.utils.citeproc(doc)

    -- now put the urls in
    return citeproc_result:walk {
        Inlines = cleanup_postcite,
        Cite = add_links
    }
end

