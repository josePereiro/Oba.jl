function selfcomment!!(cmd::ObaScriptBlockAST, cmt_str::AbstractString)

    # comment script
    cmt_str = strip(cmt_str)
    old_script = cmd[:script]
    new_lines = map(split(old_script, "\n")) do oldline
        dig = strip(oldline)
        isempty(dig) ? dig : string(cmt_str, " ", oldline)
    end
    new_script = join(new_lines, "\n")

    # write
    set_script!(cmd, new_script)
    write!!(parent_ast(cmd))

    return cmd
end

# server api
selfcomment!!(cmt_str::AbstractString) = selfcomment!!(currscript(), cmt_str)
export selfcomment!!