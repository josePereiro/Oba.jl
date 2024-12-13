## ------------------------------------------------------------------
_crossref_meta_dir(depotdir) = joinpath(depotdir, ".crossref")

function _download_crossref_meta(doi; dir = pwd(), force = false)
    name = string(_format_doi_for_filename(doi), ".json")
    outpath = joinpath(dir, name)
    force && rm(outpath; force)
    isfile(outpath) && return outpath
    try
        doi = _doi_to_url(doi)
        isempty(doi) && error("We don't like your DOI: '$(doi)'")
        mkpath(dir)
        @info("Downloading", doi)
        # cmdstr = """curl -L -H "Accept: application/vnd.crossref.unixsd+json" "$(doi)" > "$(outpath)" """
        cmdstr = """curl -G "https://api.crossref.org/works/$(doi)" > "$(outpath)" """
        run(`bash -c $(cmdstr)`; wait = true)
        sleep(0.2) # Avoid abusing the line
        @info("Done")
    catch err
        rm(outpath; force = true)
        rethrow(err)
    end
    return outpath
end

## ------------------------------------------------------------------
function _crossref_references(doi::AbstractString; dir = pwd(), force = false)
    @show doi
    outdir = _crossref_meta_dir(dir)
    jsonfile = _download_crossref_meta(doi; force, dir = outdir)
    try
        jsonstr = read(jsonfile, String)
        jsondict = JSON.parse(jsonstr)
        val = _find_key(jsondict, ["message", "reference"])
        return isnothing(val) ? [] : val
    catch err
        rm(jsonfile; force = true)
        rethrow(err)
    end
    return []
end


# ## ------------------------------------------------------------------
# # Access
# # Interface with crossref api json

# # const _DOI_REGEX = Regex("\\d{1,10}\\.\\d{3,20}/[-._;()/:a-zA-Z0-9]+")
# # function _crossref_entry_doi(ref::AbstractDict)
# #     !haskey(ref, "DOI") && return ""
# #     doistr = string(ref["DOI"])
# #     m = match(_DOI_REGEX, doistr)
# #     isnothing(m) ? "" : string(m.match)
# # end

# _crossref_entry_doi(ref::AbstractDict) = get(ref, "DOI", "")
# _crossref_entry_author(ref::AbstractDict) = get(ref, "author", "")
# _crossref_entry_year(ref::AbstractDict) = get(ref, "year", "")
# _crossref_entry_keywords(ref::AbstractDict) = get(ref, "keywords", "")

# function _crossref_entry_title(ref::AbstractDict) 
#     for key in keys(ref)
#         key == "journal-title" && continue
#         endswith(key, "-title") && return ref[key]
#     end
#     return ""
# end

# function _format_crossref_data!(ref::Dict)
    
#     # clear content
#     # doi
#     if haskey(ref, "DOI")
#         doistr = _doi_to_url(ref["DOI"])
#         !isempty(doistr) && (ref["DOI"] = doistr)
#     end

#     for (key, val) in ref
#         ref[key] = _clear_bibtex_entry(val)
#     end
# end

# function _crossref_to_rbref(dict::AbstractDict)
#     _format_crossref_data!(dict)

#     ref = RBRef()

#     # add firlds
#     set_bibkey!(ref, "")
#     set_author!(ref, _crossref_entry_author(dict))
#     set_year!(ref, _crossref_entry_year(dict))
#     set_title!(ref, _crossref_entry_title(dict))
#     set_doi!(ref, _crossref_entry_doi(dict))
#     add_tag!(ref, _crossref_entry_keywords(dict))
#     refdict!(ref, dict)

#     return ref
# end

# ## ------------------------------------------------------------------
# function crossrefs(doi::AbstractString; force = false)
#     ref_dicts = _crossref_references(doi; force)
#     refs = RBRef[]
#     for dict in ref_dicts
#         push!(refs, _crossref_to_rbref(dict))
#     end
#     return reflist(refs)
# end