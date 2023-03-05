
_bkconfig_file(os::ObaServer) = joinpath(oba_dir(os), "backup.config.jls")
_bklink_dir(os::ObaServer) = joinpath(oba_dir(os), "bklink")

# TODO: store the remote_url into the os
export VaultGitLink!
function VaultGitLink!(os::ObaServer, remote_url;
        next = 60 * 60 * 24, # s
        force = false, 
        to_commit = []
    )

    # data
    set!(os, :VaultGitLink, Dict())
    
    bklink_dir = _bklink_dir(os)
    set!(os, [:VaultGitLink], "bklink_dir",  bklink_dir)
    set!(os, [:VaultGitLink], "remote_url",  remote_url)
    
    gitlink = GitLinks.GitLink(bklink_dir, remote_url)
    set!(os, [:VaultGitLink], "gitlink",  gitlink)
    
    set!(os, [:VaultGitLink], "next",  next)
    set!(os, [:VaultGitLink], "force",  force)
    set!(os, [:VaultGitLink], "to_commit",  to_commit)
    set!(os, [:VaultGitLink], "bkconfig_file",  _bkconfig_file(os))

    

    return os
end

# Save backup
function upload_backup(os::ObaServer)

    haskey(os, :VaultGitLink) || error(":VaultGitLink key missing, you must call VaultGitLink!(os...)!!")

    # get stuff
    gl = get(os, [:VaultGitLink], "gitlink")
    remote_url = get(os, [:VaultGitLink], "remote_url")
	bkconfig_file = get(os, [:VaultGitLink], "bkconfig_file")
	next = get(os, [:VaultGitLink], "next")
	force = get(os, [:VaultGitLink], "force")
	to_commit = get(os, [:VaultGitLink], "to_commit")

    GitLinks.clear_wd(gl)
	
	# check if is time
	istime = true
	lastok = false
	elapsed = 0
    
	if isfile(bkconfig_file)
		config = deserialize(bkconfig_file)
		elapsed = time() - get(config, :last, 0)
		lastok = get(config, :okflag, false)
        elapsed = floor(Int, elapsed)
		istime = elapsed > next
	end
	if !force && !istime && lastok
		@info("No time yet", 
            elapsed = ObaBase._canonicalize(elapsed, Second), 
            next = ObaBase._canonicalize(next, Second), 
            lastok
        )
		return
	end

    # check connection
    if !GitLinks.has_connection(gl)
        @warn("No connection", remote_url)
        return
    end
    
	@info("Time to backup", 
        elapsed = ObaBase._canonicalize(elapsed, Second), 
        next = ObaBase._canonicalize(next, Second), 
        lastok
    )
	
	# Init link
	GitLinks.instantiate(gl; verbose = true)

	# try to upload
    verbose = true
    tries = 5
    okflag = GitLinks.upload_wdir(gl; tries, verbose) do wdir

        # prepare
        GitLinks.clear_wd(gl)
        GitLinks._rm(joinpath(vault_dir(os), ".git")) # a git repo is not allowed

        # copy to upload
        for name in to_commit
            @info("Staging", name)
            GitLinks._cp(
                joinpath(vault_dir(os), name), # src
                joinpath(wdir, name)        # dst
            )
        end
        
    end 

	# save config
    config = Dict(:last => time(), :okflag => okflag)
	serialize(bkconfig_file, config)

	# clear
	GitLinks.clear_wd(gl)
	
	@info("Done", okflag)

    return nothing

end