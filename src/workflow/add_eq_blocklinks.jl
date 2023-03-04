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
        link0 = string(prefix, texlabel)
        link0 = _format_block_link(link0)
        
        # check
        next_idx = min(child_idx(ch) + 1, lastindex(AST))
        next_ast = AST[next_idx]
        if isblocklinkline(next_ast)
            # at the end I will reparse! the whole AST
            next_ast.src = string("^", link0)
        else
            # I add the link to the texast, 
            # at the end I will reparse! the whole AST
            ch.src *= string("\n", "^", link0)
        end

    end # for ch in AST

    reparse!(AST)

    return AST
end

function add_eq_blocklinks!!(AST::ObaAST; prefix = "eq--") 
    add_eq_blocklinks!(AST; prefix)
    write!!(AST)
    return AST
end
