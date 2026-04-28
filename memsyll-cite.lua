--[[
    memsyll-cite.lua: run citeproc, modify output for better web-ready markdown
    Andrew Goldstone, 2026

    This filter simply creates hyperlinked citations where bibliography entries
    have URLs, which CSL alone cannot do.

    N.B. the output format on the command line must be explicitly -citations,
    otherwise citeproc is no-op.

    See citeproc.sh for example usage.

    TODO fix bad handling of closing punctuation
    TODO fix bad handling of multicites like [@cite1, @cite2]
]]

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
    return citeproc_result:walk { Cite = add_links }
end

