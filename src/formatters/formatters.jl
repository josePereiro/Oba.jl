function Formatters_init!(os::ObaServer)

    # data
    set!(os, :Formatters, Dict())
    
    # inits
    YAMLSection_formatter_init!(os)

end