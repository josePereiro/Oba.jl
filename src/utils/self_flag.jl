# server api
export self_flag!!
function self_flag!!(cmd::ObaScriptBlockAST, new_flags::String)
    hasflag(cmd, new_flags) && return cmd
    add_flags!(cmd, new_flags)
    write!!(parent_ast(cmd))
    return cmd
end