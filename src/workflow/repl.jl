function _bash_output_formatter(out)
    to_append = String[]
    push!(to_append, "```bash")
    push!(to_append, out)
    push!(to_append, "```")
    return join(to_append, "\n")
end

function repl!!(f::Function, os::ObaServer; 
        flags = "u", 
        out_formatter = _bash_output_formatter
    )

    ast = curr_ast(os)
    scr = curr_scriptast(os)
    
    !isempty(flags) && self_flag!!(scr, flags)

    out0 = capture_io(f)
    out = out_formatter(out0)

    cut_from!(scr)
    append!(ast, string("\n___\n", out))

    write!!(ast)

end