# Project VM for local development

Spins up a dev environment using Ansible - ala [DrupalVM](https://www.drupalvm.com).
It will fire two VMs, an "app" one with nginx/php and a "db"one for the database.

## Dependencies
1. Install **Vagrant** from https://www.vagrantup.com
1. Install **Virtualbox** from https://www.virtualbox.org
3. Install vagrant **vbguest** plugin:  ```vagrant plugin install vagrant-vbguest```

## Quick start

Clone this template to anything you like 

```git clone git@git.codeenigma.com:ce-drupal-dev-megazord/ce-vm.git mynewproject```

Then
1. Edit the ce-vm/config.yml file to your need
2. From the "ce-vm" folder, use "vagrant up" to start and provision the VMs.

You can then "hack" your way in the ansible playbooks at will.

## "Upstream" workflow
If you want to keep up-to-date with the main playbooks, 
and not treat this as a pure fork, you can easily do so.

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