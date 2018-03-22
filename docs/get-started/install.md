
Major Linux distributions, Mac OS X and Windows should be supported.

## Requirements

- Ensure you have a fair amount of RAM (8G recommended).
- Git must be available on your host machine

**Windows:** Ensure the git executable is accessible as `git` on the command line, not as `git.exe`

## Vagrant

Vagrant is used to orchestate and coordinate the containers, but also to make a few adjustments to the
setup based on your host OS.
The ce-vm implementation does not use VirtualBox, but Docker only, and no longer requires any additional
Vagrant plugins.

### Version
Install a recent Vagrant version from [www.vagrantup.com](https://www.vagrantup.com). 

**Linux:** Do NOT use the version from your distribution repositories; those are always outdated. Use the official version provided at [www.vagrantup.com](https://www.vagrantup.com).

**Backward compatibility** If you already have some projects using earlier 3.x version of ce-vm, 
and you don't want or can't upgrade them, 
you need to stick with the 1.9.1 version of Vagrant: This is because the versions above introduced bugs
that were later fixed in 2.0.0, but we relied on the vagrant-triggers plugin, which is only supported in
version below 1.9.7.


## Docker

Docker is used as a Vagrant provider. You need a recent version of the native app from [docker.com](https://www.docker.com/community-edition#/download).

### Mac OS host

The older "boot2docker / Docker Toolbox" implementations that were using an extra VM layer using Virtualbox are not supported by ce-vm.

### Windows host

The older "boot2docker / Docker Toolbox" implementations that were using an extra VM layer using Virtualbox are not supported by ce-vm.

### Linux host

The Docker daemon can only be managed by the root user by default. As with any other Docker-based stack, this means you either have to:

- Run each and every `vagrant` command using sudo. While this works, it also means that the ce-vm base will get installed under the root user home dir instead of yours, and that all files, including your codebase will be owned by the root user. In practice, this is very unpractical.
- Add yourself to the "docker" group, so you can run `vagrant` commands as your standard unprivileged user - see [docs.docker.com](https://docs.docker.com/engine/installation/linux/linux-postinstall/) for details. It does solve the issue, but this poses a security risk you need to be aware of and understand. See [here for details](https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface). Most users tend to just "live with it" as it is the most convenient solution.
- Use the wrapper script that is included with ce-vm. It takes a hybrid approach of temporarily adding your user to the docker group for the duration of the `vagrant` command, then removes it straight after it has run. See the [tips](/tips/scripts/#vagrant-docker-sudo.sh) section for usage.


## ce-vm

The "stack' itself will install itself when you `vagrant up` for the first time, by cloning the main ce-vm repo from https://github.com/codeenigma/ce-vm/ as ~/.CodeEnigma/ce-vm/ce-vm-upstream on your host.
