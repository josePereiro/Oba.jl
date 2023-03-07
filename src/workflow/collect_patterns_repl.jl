function collect_patterns_repl!!(os::ObaServer, dest, to_collect::AbstractVector;
        out_formatter = identity, flags = "", max_show = 100
    )

    Oba.repl!!(os; out_formatter, flags) do

        tot_found = 0
    
        Oba.foreach_noteast(os) do ast
            astfile = ast.file
            
            (ast.file == dest) && return false
            endswith(ast.file, ".oba.md") && return false
    
            asti_found = 0
            
            for pat in to_collect
                pati_found = 0
                for ch in ast
                    chsrc = source(ch)
                    contains(chsrc, pat) || continue
                    tot_found += 1
                    pati_found += 1
                    asti_found += 1
                    if (asti_found == 1) 
                        println(ObaBase._onsidian_filelink(astfile))
                    end
                    println("_line ", ch.line, ":_")
                    for line in split(chsrc, "\n")
                        println("> ", line)
                    end
                    println()

                    if tot_found >= max_show
                        println()
                        println("!!!!! MAX SHOW REACHED !!!!!")
                        println("max_show: ", max_show)
                        return true
                    end
                end
            end
            
            (asti_found > 0) && println("___")
    
        end # foreach_noteast
    end
end
