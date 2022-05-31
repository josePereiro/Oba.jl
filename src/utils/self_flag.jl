# server api
export self_flag!
function self_flag!(new_flags::String)
    cmd = currscript()
    add_flags!(cmd, new_flags)
    write!(parent_ast(cmd))
    return cmd
end