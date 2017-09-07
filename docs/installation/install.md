Major Linux distributions, Mac OS X and Windows should be supported.

# Requirements

- Ensure you have a fair amount of RAM (8G recommended).
- Git must be available on your host machine

**Windows:** Ensure the git executable is accessible as `git` on the command line, not as `git.exe`

# Vagrant

Install latest Vagrant version from [www.vagrantup.com](https://www.vagrantup.com).

**Linux:** Do NOT use the version from your distribution repositories, those are always outdated. Use the official version provided at [www.vagrantup.com](https://www.vagrantup.com).

Also install the vbguest and triggers plugins:

```vagrant plugin install vagrant-vbguest```

```vagrant plugin install vagrant-triggers```

# Providers

Either VirtualBox or Docker can be used as provider. Which one to choose depends mostly on your host OS and your knowledge of the underlying tech.

Docker integration is less tested on our side, and does not bring any performance gain on Mac OS or Windows (actually it is still far slower unless you use the Edge version). The only host platform where Docker brings a real performance gain is Linux, but has several caveats (see section below).

In a nutshell: VirtualBox is the failsafe option, you should stick with it unless you are on Linux AND you are familiar with Docker filesystem mount permissions.

## VirtualBox provider

Make sure you have the latest version from [www.virtualbox.org](https://www.virtualbox.org).

**Linux:** Do NOT use the version from your distribution repositories, those are always outdated. Use the official version provided at [www.virtualbox.org](https://www.virtualbox.org).

It should work out of the box on all platforms, but you should check the file sharing options for better performances.


## Docker provider

### Mac OS host

You will need to install the "Edge" version from [docs.docker.com](https://docs.docker.com/docker-for-mac/install/).

No further configuration should be needed, besides allocating enough memory to the daemon in the Docker app preferences.

*It is in practice possible to use ce-vm with the stable Docker release by adding an entry for `127.0.0.1 app-vm.codeenigma.com` in your /etc/hosts files, but the performances are (as of this writing) really, really poor due to the bind/mount filesystem.*

### Windows host

We don't have anyone using Windows internally, so this is untested, but instructions should be the same than on Mac OS. 

Simply install the "Edge" version from [docs.docker.com](https://docs.docker.com/docker-for-windows/install/).