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

### Linux host

Refer to [docs.docker.com](https://docs.docker.com/engine/installation/) for the daemon installation for your platform.

Running Docker on a Linux host presents a significant performance boost over VirtualBox. This is due to the fact that shared folders are actually direct mount and do not need any binding. This is also the cause for the main issues you will face.

In practice, this means there is no user mapping on file ownership of the directories accessed by both your host and the container, so user and group will be the same for both.

#### Issue 1. Docker run as root

The Docker daemon can only be managed by the root user by default. This means you either have to:

- Run each and every `vagrant` command using sudo. While this work, it also mean that the ce-vm base will get installed under the root user home dir instead of yours, and that all files, including your codebase will be owned by the root user.
- Add yourself to the "docker" group, so you can run `vagrant` commands as your standard unprivileged user (see [docs.docker.com](https://docs.docker.com/engine/installation/linux/linux-postinstall/) for details. It does partially solve the issue, but:
  1. This poses a security risk you need to be aware of and understand. See [https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface](https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface). You can also have a look at [https://www.projectatomic.io/blog/2015/08/why-we-dont-let-non-root-users-run-docker-in-centos-fedora-or-rhel/](https://www.projectatomic.io/blog/2015/08/why-we-dont-let-non-root-users-run-docker-in-centos-fedora-or-rhel/) for alternative approaches.

#### Issue 2. File ownership

As explained above, contrary to the non-native implementation on Mac or Windows, 
there is no mapping of ownership on the filesystem. 
A file owned by user "vagrant" (1001) or "www-data" (33) on the container 
will have the same numeric owner (1001 or 33 in our example) on the host machine. 
If your user id on the host is 1001, which is the most common situation, 
you should be fine. We working on a solution for other cases.

# ce-vm

The "stack' itself will install itself when you `vagrant up` for the time.

1. Generate a skeleton at http://ce-vm.codeenigma.net/ and extract it
2. Review the generated config.yml file
3. Fire up your first instance: `cd ce-vm && vagrant up`

This will git clone the main ce-vm repo from https://github.com/codeenigma/ce-vm/ 
as ~/.CodeEnigma/ce-vm/ce-vm-upstream on your host.

**Note: there is a known issue that prevent the first ever instance you launch 
to be properly provisioned. Re-trigger the provisioning 
with `vagrant reload --provision`. This is not needed for subsequent instances.**