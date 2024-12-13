
module Oba

    import Reexport: @reexport
    @reexport using ObaBase
    @reexport using ObaASTs
    @reexport using FilesTreeTools
    @reexport using ObaServers
    using MassExport

    #! include .
    
    #! include crossref
    include("crossref/crossref.jl")
    include("crossref/utils.jl")
    
    #! include replace
    include("replace/str_replace.jl")
    
    @exportall_non_underscore

end