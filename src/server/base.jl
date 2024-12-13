# ..-- - .- .--- .- .- .- -- .- .-.-. -.- .- .-.-. -.--- - 
function Oba_run_init!(onsetup::Function, vault_dir::AbstractString;
        kwargs...
    )

    ObaServer_run_init!(vault_dir; kwargs...) do

        # run registered callbacks
        for cb! in OBA_ONSETUP_CALLBACKS
            cb!()
        end
        
        # run direct
        onsetup()

    end


end

# ..-- - .- .--- .- .- .- -- .- .-.-. -.- .- .-.-. -.--- - 
function Oba_run_loop!(oniter::Function)

    ObaServer_run_loop!() do
        # run registered callbacks

        # run registered callbacks
        for cb! in OBA_ONITER_CALLBACKS
            cb!()
        end
        
        # run direct
        oniter()
    end
end


## ..- .- - .- .- .- .- .-.-.-.-.-.  ...-- - . .. . .
function obaserver_script()
    println(
        """
            # This is the entry point for the obaserver
            # ..- .- - .- .- .- .- .-.-.-.-.-.  ...-- - . .. . .
            using Oba

            ## ..- .- - .- .- .- .- .-.-.-.-.-.  ...-- - . .. . .
            # Run server
            let
                # setup
                vault_dir = joinpath(@__DIR__)

                # init
                Oba_run_init!(vault_dir) do
                    # Place here onsetup code
                end

                # loop
                Oba_run_loop!() do
                    # Place here oniter code
                end
            end
        """
    )
end