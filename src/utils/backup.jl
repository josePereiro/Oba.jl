_bkconfig_file() = joinpath(obadir(), "backup.config.jls")
_bklink_dir() = joinpath(obadir(), "bklink")

function VaultGitLink(remote_url)
    root_dir = _bklink_dir()
    return GitLinks.GitLink(root_dir, remote_url)
end

# Save backup
function upload_backup(remote_url::AbstractString; 
        next = 60 * 60 * 24, # s
        force = false, 
        to_commit = []
    )

    # link
    gl = VaultGitLink(remote_url)
    GitLinks.clear_wd(gl)
	
	# check if is time
	bkfile = _bkconfig_file()
	istime = true
	lastok = false
	elapsed = 0
	if isfile(bkfile)
		config = deserialize(bkfile)
		elapsed = time() - get(config, :last, 0)
		lastok = get(config, :okflag, false)
        elapsed = floor(Int, elapsed)
		istime = elapsed > next
	end
	if !force && !istime && lastok
		@info("No time yet", elapsed, next, lastok)
		return
	end

    # check connection
    if !GitLinks.has_connection(gl)
        @warn("No connection", remote_url)
        return
    end
    
	@info("Time to backup", elapsed, next, lastok)
	
	# Init link
	GitLinks.instantiate(gl; verbose = true)

	# try to upload
    verbose = true
    tries = 5
    okflag = GitLinks.upload_wdir(gl; tries, verbose) do wdir

        # prepare
        GitLinks.clear_wd(gl)
        GitLinks._rm(joinpath(vaultdir(), ".git")) # a git repo is not allowed

        # copy to upload
        for name in to_commit
            @info("Staging", name)
            GitLinks._cp(
                joinpath(vaultdir(), name), # src
                joinpath(wdir, name)        # dst
            )
        end
        
    end 

	# save config
    config = Dict(:last => time(), :okflag => okflag)
	serialize(bkfile, config)

	# clear
	GitLinks.clear_wd(gl)
	
	@info("Done", okflag)

    return nothing

end