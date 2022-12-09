
# ------------------------------------------------------------------
# template
const SECTION_TEMPLATE_KEY = "{{OBA: SECTION}}"
const PREVIOUS_TEMPLATE_KEY = "{{OBA: PREVIOUS}}"
const NEXT_TEMPLATE_KEY = "{{OBA: NEXT}}"
const HOME_TEMPLATE_KEY = "{{OBA: HOME}}"

function _extract_section_to_file_dflt_template()
    """
    ---
    creation-date: "$DATE_TEMPLATE_KEY"
    ---

    $HOME_TEMPLATE_KEY
    <<< $PREVIOUS_TEMPLATE_KEY : $NEXT_TEMPLATE_KEY >>>

    $SECTION_TEMPLATE_KEY
    
    """
end

# ------------------------------------------------------------------
function _template_replace_home(template, home)
    link = string("[[", basename(home), "|home]]")
    return replace(template, HOME_TEMPLATE_KEY => link)
end

function _template_replace_sections(template, section_asts)
    section = source(section_asts)
    return replace(template, SECTION_TEMPLATE_KEY => section)
end

function _template_replace_previous(template, previous)
    link = string("[[", basename(previous), "|previous]]")
    return replace(template, PREVIOUS_TEMPLATE_KEY => link)
end

function _template_replace_next(template, next)
    link = string("[[", basename(next), "|next]]")
    return replace(template, NEXT_TEMPLATE_KEY => link)
end

# ------------------------------------------------------------------
"""

Accept a `template` and insert the extraction at {{OBA: SECTION}}
Other keys {{OBA: SECTION[idx]}} {{OBA: PREVIOUS}} {{OBA: NEXT}} {{OBA: HOME}}
"""
function extract_section_to_file!(AST::ObaAST, lvl::Integer; 
        start = firstindex(AST),
        rename_mask = r".*",
        dir = dirname(parent_file(AST)),
        force = true,
        template::Union{Nothing, String} = _extract_section_to_file_dflt_template() 
    )

    start = child_idx(start)

    top_headers = HeaderLineAST[]
    iter_from(AST, start, 1) do idx, ch
        ch isa HeaderLineAST && ch[:lvl] == lvl && push!(top_headers, ch)
        return
    end

    file_paths = map(top_headers) do header_ast
        name = header_to_filename(header_ast, rename_mask)
        return joinpath(dir, name)
    end


    for (i, (header_ast, path)) in enumerate(zip(top_headers, file_paths))

        section_asts = collect_section(header_ast)
        force || isfile(path) && error("file already exists, file: ", path)

        if isnothing(template)
            write(path, section_asts)
        else
            # handle template
            txt = _templates_replace_standards(template)
            txt = _template_replace_home(txt, parent_file(header_ast))
            txt = _template_replace_sections(txt, section_asts)
            if isinbound(file_paths, i - 1)
                txt = _template_replace_previous(txt, file_paths[i - 1])
            end
            if isinbound(file_paths, i + 1)
                txt = _template_replace_next(txt, file_paths[i + 1])
            end
            write(path, txt)
        end
    end

    # make index
    for (i, (header_ast, path)) in enumerate(zip(top_headers, file_paths))
        
        section_asts = collect_section(header_ast)

        # delete section
        for ast in section_asts
            ast isa HeaderLineAST && ast[:lvl] == lvl && continue # save header
            Base.deleteat!(AST::ObaAST, ast)
        end

        # change to link
        file_link, ext = splitext(basename(path))
        title = header_ast[:title]
        header_ast.src = string("[[", file_link, "|", title, "]]")

    end
    
    write!(AST)

    return file_paths
end