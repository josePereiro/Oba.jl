# ..-- - .- .--- .- .- .- -- .- .-.-. -.- .- .-.-. -.--- - 
_push!(f::Function, reg::Vector{Function}) = push!(reg, f)

# ..-- - .- .--- .- .- .- -- .- .-.-. -.- .- .-.-. -.--- - 
# On setup callbacks
const OBA_ONSETUP_CALLBACKS = Function[]

_push!(OBA_ONSETUP_CALLBACKS) do
    
    # ..-- - .- .--- .- .- .- -- .- .-.-. -.- .- .-.-. -.--- - 
    # replace/expand
    register_callback!("Vault.callbacks.note.onupdate") do

        # TODO: connect with config file 
        # - Add 'pt -> function' from outside
        fn = first(getstate("Callbacks.call.args"))::String
        line_replace(fn, 
            "#!cdate" => _formatted_timetag(ctime(fn)), 
            "#!mdate" => _formatted_timetag(mtime(fn)), 
            "#!date" => _formatted_timetag(time()), 
        )
    end

end

# ..-- - .- .--- .- .- .- -- .- .-.-. -.- .- .-.-. -.--- - 
# On setup callbacks

const OBA_ONITER_CALLBACKS = Function[]

_push!(OBA_ONITER_CALLBACKS) do
    # add callbacks here
end