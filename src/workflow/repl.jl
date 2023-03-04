function _bash_output_formatter(out)
    to_append = String[]
    push!(to_append, "")
    push!(to_append, "___")
    push!(to_append, "```bash")
    push!(to_append, out)
    push!(to_append, "```")
    return join(to_append, "\n")
end

function repl!!(f::Function; 
        flags = "u", 
        out_formatter = _bash_output_formatter
    )

    ast = currast()
    scr = currscript()
    @show scr
    
    !isempty(flags) && self_flag!!(flags)

    out = capture_io(f)

    cut_from!(scr)
    append!(ast, out_formatter(out))

    write!!(ast)

end