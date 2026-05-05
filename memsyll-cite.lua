--[[
    memsyll-cite.lua: run citeproc, modify output for better web-ready markdown
    Andrew Goldstone, 2026

    See citeproc.sh for example usage. This filter does two chores:

    1. Create hyperlinked citations where bibliography entries
    have URLs, which CSL alone apparently cannot do.

    N.B. the output format on the command line must be explicitly -citations,
    otherwise citeproc is no-op.

    2. Clean up punctuation when a citation ends with quotation marks and is
    followed by a period or comma. I like to see that punctuation moved inside
    the quotation marks (Chicago style), but again citeproc/CSL seem to fail.

    Known issues:

    TODO fix bad handling of multicites like [@cite1, @cite2]
]]

-- local logging = require "logging"

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
-- and moving them i. It's not elegant but I think it works okay

local close_quote = lpeg.S("\"'”’") -- curly or straight
local close_punct = lpeg.S(",.") * -1 -- [,.]$
-- pattern to check for: a terminal close-quote
local cleanup_pat = (1 - close_quote^1 * -1)^0 * lpeg.C(close_quote^1) * -1

local function cleanup_postcite (il)
    for i = #il, 1, -1 do
        if il[i].t == "Cite" and il[i + 1] and il[i + 1].t == "Str" and
            close_punct:match(il[i + 1].text) then
            local qmatch = cleanup_pat:match(pandoc.utils.stringify(il[i]))

            if qmatch then
                local qq = utf8.len(qmatch) -- error-check counter

--[[

a Cite always has Inlines for content, but these can themselves be nested,
so we have to traverse the tree to check where our innermost close-quote
really lives.

We start by setting `node` to the content of the Cite. Then:

node is a Str:
    is it a close quote? then we're not done, we need to look one element to the left
    is it some other string? then we're done, remember where we are and put closing punct after it

node is a list of Inlines:
    starting from the right, recurse on its elements

otherwise:
    node is a container, repeat on its content

---]]

                local function traversal (node, parent)
                    if not node then
                        io.stderr:write(
                "Error in punctuation cleanup: fell off the tree. Giving up.\n")
                        return nil, nil
                    end

                    if node.t == "Str" then
                        -- leaf case: we're looking for the first non-quote Str
                        local test = close_quote:match(node.text)
                        if (test) then
                            qq = qq - 1
                            return nil, nil
                        else
                            local _, result  = parent:find(node)
                            return parent, result + 1
                        end
                    elseif pandoc.utils.type(node) == "Inlines" then
                        local ins = #node
                        while ins > 0 do
                            -- it's not a tail recursion, what do you want
                            local rnode, rloc = traversal(node[ins], node)

                            if rnode then
                                return rnode, rloc
                            else
                                ins = ins - 1
                            end
                        end
                    else -- generic case: node must be a container
                        return traversal(node.content, node)
                    end
                end

                local target, loc = traversal(il[i].content, il[i])

                if (qq > 0) then
                    io.stderr:write(
            "Error in punctuation cleanup: missed a quote mark. Giving up.\n")
                elseif not target then
                    io.stderr:write(
                "Error in punctuation cleanup: fell off the tree. Giving up.\n")
                else
                    target:insert(loc, il:remove(i + 1))
                end

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
    doc = pandoc.utils.citeproc(doc)

    -- now put the urls in
    doc = doc:walk {
        Inlines = cleanup_postcite
    }
    doc = doc:walk {
        Cite = add_links
    }

    return doc
end

