#TODO: create a Selection object, to handle (among other things) the range.
# I want to be able to modified the selection and included in the AST write.


# ------------------------------------------------------------------
function _match_childs_from(reg::Regex, line_AST::AbstractObaASTChild, iter_fun::Function)

    not_found = Int[] # collect int in case it fails not to allocate much
    found = nothing
    pos = nothing

    iter_fun(line_AST) do i, ch
        rm = match_src(reg, ch)
        if isnothing(rm)
            push!(not_found, i)
            return false
        else
            found = ch
            pos = _match_pos(rm)
            return true
        end
    end

    return not_found, found, pos
end

"""
Select a portion of txt from the caller position UP till the first hit of the regex.
Error if the regex is missed.
Returns the selected text
"""
function select_above(r0::Regex)

    line_AST = currscript()

    not_found, found, match_pos = _match_childs_from(r0, line_AST, (f, ch) -> iter_from(f, ch, 1, 1) )

    isnothing(found) && error("Regex", r0, " do not match any child!!")
    
    return string(
        source(found)[first(match_pos):end],
        "\n",
        source(parent_ast(line_AST), reverse(not_found))
    )
end

function select_above(r0::Regex, r1::Regex)

    sel = select_above(r0)
    last_rm = nothing
    for rm in eachmatch(r1, sel)
        last_rm = rm
    end
    isnothing(last_rm) && error("Regex", r1, " do not match any child!!")

    pos = _match_pos(last_rm)

    return sel[begin:last(pos)]
end

export select_above

# ------------------------------------------------------------------
"""
Select a portion of txt from the caller position DOWN till the first hit of the regex.
Error if the regex is missed.
Returns the selected text
"""
function select_below(r0::Regex)

    line_AST = currscript()

    not_found, found, match_pos = _match_childs_from(r0, line_AST, (f, ch) -> iter_from(f, ch, -1, -1))

    isnothing(found) && error("Regex", r0, " do not match any child!!")
    
    return string(
        source(parent_ast(line_AST), not_found),
        "\n",
        source(found)[begin:last(match_pos)],
    )
end


function select_below(r0::Regex, r1::Regex)
    
    sel = select_below(r1)
    first_rm = match(r0, sel)
    isnothing(first_rm) && error("Regex", r0, " do not match any child!!")

    pos = _match_pos(first_rm)

    return sel[first(pos):end]
end

export select_below