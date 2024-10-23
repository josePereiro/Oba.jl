function _doi_to_url(doi)
    if startswith(doi, "http")
        return doi 
    elseif startswith(doi, "doi.org")
        return string("https://", doi)
    elseif startswith(doi, r"\d{1,10}\.\d{3,20}")
        return string("https://doi.org/", doi)
    end
    return ""
end

function _format_doi_for_filename(doi)
    url = _doi_to_url(doi)
    replace(url, r"[^a-zA-Z0-9]" => "_")
end

# Search a multilayer Dict for a given key
function _find_key(dict::AbstractDict, key)
    for (ikey, val) in dict
        (ikey == key) && return val
        if (val isa AbstractDict)
            val = _find_key(val, key)
            !isnothing(val) && return val
        end
    end
    return nothing
end

# Search a multilayer Dict for a given set of keys
function _find_key(dict::AbstractDict, keys::Vector)
    for key in keys
        dict = _find_key(dict, key)
        isnothing(dict) && break
    end
    return dict
end

function _till_unchanged(f::Function, str0)
    str0 = string(str0)
    while true
        str = f(str0)::AbstractString
        (str == str0) && return str
        str0 = str
    end
end

const _CLEAR_BIBTEX_ENTRY_STRIP_SET = ['{', '}', '\n', ' ', ',', ';']
function _clear_bibtex_entry(str0::AbstractString)
    return _till_unchanged(str0) do str
        str = strip(str, _CLEAR_BIBTEX_ENTRY_STRIP_SET)
        str = replace(str, "{" => "")
        str = replace(str, "}" => "")
        str = replace(str, "\\" => "")
        str = replace(str, " ," => ",")
        str = replace(str, "`" => "")
        str = replace(str, "'" => "")
        str = replace(str, "  " => " ")
        str = replace(str, "\"" => "")
        return str
    end
end