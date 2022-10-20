function repl_!u(f::Function)

    ast = currast()
    scr = currscript()
    
    self_flag!("u")

    out = capture_io() do
        f()
    end

    cut_from!(scr)
    to_append = String[]
    push!(to_append, "")
    push!(to_append, "___")
    push!(to_append, "```bash")
    push!(to_append, out)
    push!(to_append, "```")
    to_append = join(to_append, "\n")
    append!(ast, to_append)

    write!(ast)

end