function YAMLSection_formatter_init!(os::ObaServer)

    # data
    set!(os, [:Formatters], "YAMLSection", Dict())
    
    # last hashes
    cache_file = joinpath(oba_dir(os), "_yaml_formatter_hashes_cache.jls")
    set!(os, [:Formatters, "YAMLSection"], "last_hashes_cache", cache_file)
    last_hashes = Dict()
    if isfile(cache_file)
        try; 
            last_hashes = deserialize(cache_file)
            catch err; rm(cache_file; force = true)
        end
    end
    set!(os, [:Formatters, "YAMLSection"], "last_hashes", last_hashes)

    register_callback!(os, (:FileTracker, :on_content_changed), Oba, :_yaml_formatter_cbs, 100)

end

_tryparse(date_str, ::Nothing) = tryparse(DateTime, date_str)
_tryparse(date_str, format) = try; DateTime(date_str, format); catch err; nothing; end

# call at (:FileTracker, :on_content_changed)
function _yaml_formatter!!(os::ObaServer, ast::ObaAST)

    # load
    ych = yaml_ast(ast)
    isnothing(ych) && return nothing
    ydict = yaml_dict(ych)
    
    # check hashes (base case)
    curr_hash = hash(source(ych))
    last_hashes = get(os, [:Formatters, "YAMLSection"], "last_hashes")
    last_hash = get(last_hashes, ast.file, -1)
    curr_hash == last_hash && return nothing
    
    # creation-date
    format = "yyyy:mm:dd-HH:MM:SS"
    date_str = string(get(ydict, "creation-date", ""))
    date = nothing
    for format in [nothing, format]
        isempty(date_str) && break
        date = _tryparse(date_str, format)
        isnothing(date) || break
    end
    date = isnothing(date) ? now() : date
    date = Dates.format(date, format)
    ydict["creation-date"] = string(date)
    
    # write
    resource!(ych, ydict)

    # write
    write!!(ast)
    
    # cache
    ych = yaml_ast(ast)
    curr_hash = hash(source(ych))
    last_hashes[ast.file] = curr_hash
    cache_file = get(os, [:Formatters, "YAMLSection"], "last_hashes_cache")
    serialize(cache_file, last_hashes)

    _info("YAML Formatted", "."; 
        file = ast.file, 
        curr_hash, last_hash
    )

    return nothing
end

function _yaml_formatter_cbs(os, key, file) 
    _yaml_formatter!!(os, noteast(os, file))
end
