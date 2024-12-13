function file_replace(fn::String, pt0::Pair, pts::Pair...)
    # load
    src0 = read(fn, String)
    src = src0
    
    # expand creation time
    for pt in [pt0; pts...]
        src = replace(src, pt)
    end
    
    # write
    ismod = src != src0
    if ismod
        @show fn
        open(fn, "w") do io
            write(io, src)
        end
    end
end

function line_replace(fn::String, pt0::Pair, pts::Pair...)

    # replace
    _changed = false
    _new_lines = String[]
    for _old_line in eachline(fn)
        # replace
        _new_line = _old_line
        for pt in [pt0; pts...]
            _new_line = replace(_line, pt)
        end  
        push!(_new_lines, _new_line)
        _changed = _changed || (_old_line == _new_line)
    end

    # write
    if _changed 
        @show fn
        open(fn, "w") do io
            src = join(_new_lines, "\n")
            write(io, src)
        end
    end

    return nothing
end