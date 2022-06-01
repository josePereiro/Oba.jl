function _format_block_link(src)
    src = replace(src, r"[^A-Ba-z0-9\-]" => "-")
    return src
end

function add_eq_blocklinks!(AST::ObaAST; prefix = "eq--")
    
    for ch in AST
        islatexblock(ch) || continue
        textag_ast = get(ch, :tag, nothing)
        isnothing(textag_ast) && continue
        texlabel = get(textag_ast, :label, "")
        isempty(texlabel) && continue
        link0 = string(prefix, texlabel) |> _format_block_link
        
        next_idx = findnext(ch) do ch
            !isemptyline(ch)
        end
        
        haslink = false
        if !isnothing(next_idx) 
            next_ast = AST[next_idx]
            if isblocklinkline(next_ast)
                link1 = get(next_ast, :label, "")
                haslink = link1 == link0
            end
        end

        if !haslink
            # I add the link to the texast, at the end I will reparse! the whole AST
            ch.src *= string("\n", "^", link0)
        end
    end

    reparse!(AST)

    return AST
end
