
module Oba

    import Reexport: @reexport
    @reexport using ObaBase
    @reexport using ObaASTs
    @reexport using FilesTreeTools
    @reexport using ObaServers

    #! include .
    
    #! include crossref
    include("crossref/crossref.jl")
    include("crossref/utils.jl")
    
    export obadir

end