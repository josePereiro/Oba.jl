# server api
export self_flag!!
function self_flag!!(os::ObaServer, new_flags::String)
    cmd = curr_scriptast(os)
    hasflag(cmd, new_flags) && return cmd
    add_flags!(cmd, new_flags)
    write!!(parent_ast(cmd))
    return cmd
end