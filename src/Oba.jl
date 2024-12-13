
module Oba

    import Reexport: @reexport
    @reexport using ObaBase
    @reexport using ObaASTs
    @reexport using FilesTreeTools
    @reexport using ObaServers
    @reexport using Dates
    using MassExport

    #! include .
    
    #! include crossref
    include("crossref/crossref.jl")
    include("crossref/utils.jl")
    
    #! include server
    include("server/base.jl")
    include("server/callbacks.jl")
    
    #! include replace
    include("replace/str_replace.jl")
    
    @exportall_non_underscore

end