# Project virtual machines for local web development

Spins up a dev environment using Ansible - ala [DrupalVM](https://www.drupalvm.com).
It will fire two VMs, an "app" server with nginx/php and a "db" server for the database.
This is because we find the performance is significantly better with a pair of VMs.

## Dependencies

Supported on all systems that natively support Vagrant, e.g. Windows, most main
distributions of Linux and Apple's OSX.

All the following should be latest version possible on your system:

1. Install **Vagrant** from https://www.vagrantup.com
1. Install **Virtualbox** from https://www.virtualbox.org
3. Install vagrant **vbguest** plugin:  ```vagrant plugin install vagrant-vbguest```
4. Install vagrant **trigger** plugin: ```vagrant plugin install vagrant-triggers```

## Quick start

Download and extract this template, rename it to match your project name and put it
wherever you want it:
[GitHub generated zip](https://github.com/codeenigma/ce-vm/archive/master.zip)

Then:

1. Edit the "ce-vm/config.yml" file to meet your needs
2. From within the "ce-vm" folder, use ```vagrant up``` to start and provision the VMs
3. Go make a cup of tea while Ansible does its thing

When you get back, you'll find a clean Drupal 8 installation waiting for you at:

http://192.168.56.2

There will be a new "www" folder next to "ce-vm" which contains your Drupal code.

You can then "hack" away at the Ansible playbooks at will. If you make changes,
just ```vagrant provision``` in the "ce-vm" folder to apply them.

You can also open that "www" directory in your favourite IDE and hack away at Drupal!

## "Upstream" workflow

If you want to keep up-to-date with the main playbooks, 
and not treat this as a pure fork, you can easily do so:

### Additional requirements

1. Install vagrant triggers plugin: ```vagrant plugin install vagrant-triggers```
2. Ensure "git" is accessible on your host computer.

### Usage

You can then set the "ce_vm_upstream" flag to yes in your config.yml file.
This will clone the base repo under ~./CodeEnigma, and use these playbooks
before cloning the local ones.

This also means you can get rid of pretty much anything under the "ansible"
folder for your project and only keep what you need to behave differently
than the default.

## Using with existing Drupal applications

Already have Drupal set up? No problem. Just rename the directory Drupal is in
to "www" and move it within folder you extracted our Zip file to, so it sits
alongside the "ce-vm" folder. Then your VMs will automatically mount and 
install your Drupal website.

If you're using another platform where the Drupal folder needs to be something
else, such as "docroot", just change the "webroot" line in config.yml.

The installed Drupal will still be a clean install, so you'll need to seed
the database, and possibly the Drupal files directory too. The easiest way to
seed the database is to use [```drush```](https://github.com/drush-ops/drush).

1. On the server / computer where your work is, ```drush sql-dump > backup.sql```
2. Copy "backup.sql" to your project folder
3. Move to the "ce-vm" folder there in a terminal and ```vagrant ssh``` (log into the VM)
4. On your VM ```cd /vagrant/www``` (move to the Drupal folder)
5. Then ```drush sql-cli < /vagrant/backup.sql``` (restore the backup)
6. Finally ```drush cc all``` (clear the cache)
7. To leave the VM, type ```exit``` and press Enter

That's it! Your database is now seeded. The 
[Stage File Proxy module for Drupal](https://www.drupal.org/project/stage_file_proxy)
is the most efficient way to handle files, if you have a staging site somewhere
online. It automatically connects Drupal to files on your stage site, so you
don't need to manually place them on your local VM.

## Other useful suggestions

At Code Enigma we have a DNS entry that points app-vm.codeenigma.com to
192.168.56.2 so there is no need to mess with hosts files to use local
development environments - anything.app-vm.codeenigma.com resolves to your local
VMs. You may use this if you wish, if your project is for ACME, you can make
a local vhost on the app server for acme.app-vm.codeenigma.com and this will 
just work, no hosts entries required.

There is an option to use NFS for mounting your codebase, instead of the inbuilt
VirtualBox file system. It can be a tricky to set up, but it is a fair bit
quicker. See comments in "ce-vm/config.yml" for details.

## Roadmap

The next thing we'll be working on is Docker support. Vagrant natively wraps
Docker, but we have focused on VirtualBox for a first release, because it is
a more mature product and performs more consistently across all the target
platforms.

After that, we're open to suggestion! Also be sure to check the [contributing/maintainers guide](https://github.com/codeenigma/ce-vm/blob/master/README.md)
