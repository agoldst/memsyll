-- table of ids of references to add links to
local to_link = { }

-- link-adder, called below after to_link has been populated
local function add_links(cite)
    -- check if the citation is on our list of cites with URLs
    -- TODO what if more than one citation in the Cite?
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
    local refs = pandoc.utils.references(doc)
    for ref in refs:iter() do
        if ref.url then
            -- remember which refs have URLs
            to_link[ref.id] = ref.url
        end
    end

    --call citeproc so we can then munge the results
    --output format must have citations disabled, e.g. markdown-citations
    local citeproc_result = pandoc.utils.citeproc(doc)

    -- now put the urls in
    return citeproc_result:walk { Cite = add_links }
end

