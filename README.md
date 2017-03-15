# Project virtual machines for local Drupal development

Spins up a dev environment using Ansible - ala [DrupalVM](https://www.drupalvm.com).
It will fire two VMs, an "app" server with nginx/php and a "db" server for the database.
This is because we find the performance is significantly better with a pair of VMs.

## Dependencies
1. Install **Vagrant** >=1.9.2 from https://www.vagrantup.com
1. Install **Virtualbox** >=5.1.16 from https://www.virtualbox.org
3. Install vagrant **vbguest** plugin:  ```vagrant plugin install vagrant-vbguest```
4. Install vagrant **trigger** plugin: ```vagrant plugin install vagrant-triggers```

## Quick start

Download and extract this template, renaming it to your liking: 
https://github.com/codeenigma/ce-vm/archive/master.zip

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
