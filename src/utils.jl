# ------------------------------------------------------------------
function _get_match(rmatch::RegexMatch, ksym::Symbol, dflt = nothing) 
    cap = rmatch[ksym]
    return isnothing(cap) ? dflt : string(cap)
end

# ------------------------------------------------------------------
function _match_pos(rm::RegexMatch) 
    i0 = rm.offset
    i1 = i0 + length(rm.match) - 1
    return i0:i1
end

# ------------------------------------------------------------------
function foreach_file(f::Function, vault, ext = ".md"; keepout = [".obsidian", ".git"])
    walkdown(vault; keepout) do path
        !endswith(path, ext) && return
        f(path)
    end
end

# ------------------------------------------------------------------
function findall_files(vault::AbstractString, ext = ".md";
        sortby = mtime, sortrev = false, keepout = [".obsidian", ".git"]
    )

    files = filterdown((path) -> endswith(path, ext), vault; keepout)
    
    sort!(files; by = sortby, rev = sortrev)

    return files
end


# ------------------------------------------------------------------
const START_UP_FILE_NAME = "startup.oba.jl"
function find_startup(vault; keepout = [".obsidian", ".git"])
    path = ""
    walkdown(vault; keepout) do path_
        if basename(path_) == "startup.oba.jl"
            path = path_
            return true
        end
        return false
    end
    return path
end

## ------------------------------------------------------------------
"""
header_to_filename(header_ast::HeaderLineAST, rename_mask::Regex = r""; join = true)
    Produce a tentative file name for a section given a header ast.
    Additionally, a `rename_mask` can be passed to extract a patter in the header which will be use
    in the name.
    The join option uses the name, and extension of the parent file in the section name
"""
function header_to_filename(header_ast::HeaderLineAST, rename_mask::Regex = r""; join = true)
    title = strip(header_ast[:title])
    masked = match(rename_mask, title)
    isnothing(masked) && error("mask failed to match:\ntitle: '", title, "'\nmask: ", rename_mask)
    topfilename, ext = splitext(basename(parent_file(header_ast)))
    join ? string(topfilename, " -- ", masked.match, ext) : string(masked.match)
end

## ------------------------------------------------------------------
"""
collect_section(header_ast::HeaderLineAST)
    
    Follows the semantics of the markdown file and collects all the ast's under a given header
"""
function collect_section(header_ast::HeaderLineAST)
    top_lvl = header_ast[:lvl]
    col = AbstractObaASTChild[header_ast]
    iter_from(header_ast, 1, 1) do _, ch
        if ch isa HeaderLineAST 
            ch[:lvl] <= top_lvl && return true
        end
        push!(col, ch)
        return false
    end
    return col
end

## ------------------------------------------------------------------
isinbound(col, idx::Integer) = firstindex(col) <= idx <= lastindex(col)

## ------------------------------------------------------------------
function getclamp(col, idx::Integer)
    idx = clamp(idx, firstindex(col), lastindex(col))
    return col[idx]
end

## ------------------------------------------------------------------
function capture_io(f::Function; onerr = (err) -> nothing)  
    outfile = tempname()
    mkpath(dirname(outfile))
    rm(outfile; force = true)
    redirect_stdio(; stdout = outfile, stderr = outfile) do
        try
            f()
        catch err
            println("\n", sprint(showerror, err, catch_backtrace()))
            onerr(err)
        end
    end
    out = read(outfile, String)
    rm(outfile; force = true)
    return out
end