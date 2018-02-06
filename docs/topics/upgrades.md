
## Minor updates

Minor updates to the ce-vm stack are normally backward compatible, and performed automatically on each vagrant up/halt.
You can turn off the automatic pulling by setting the "ce_vm_upstream_auto_pull" variable to "false".

## Major updates
Any updates that break backward compatibilty (change in Vagrantfile, structure, ...) is considered a "major" release and is not automatically applied.

It is normally possible to keep using different major version in parallel (eg. 3.x for some projects, 4.x for others), so existing projects should still continue to work without porting them to a new version. 
After a while though, version requirements for Vagrant/Docker/VBox will necessarily diverge.

### 3.x > 4.x
Version 4.x drops support for VirtualBox, and remove the use of the vagrant-triggers plugin (as it is not longer maintained). If you want your existing project to continue working, stick with Vagrant 1.9.1.
#### Porting existing projects
Replace the project Vagrantfile with the one from [https://github.com/codeenigma/ce-vm-model/blob/4.x/ce-vm/Vagrantfile](https://github.com/codeenigma/ce-vm-model/blob/4.x/ce-vm/Vagrantfile).

### 2.x > 3.x
Version 3.x brings changes in the structure of projects, and introduces a split between the boilerplate/template project and the core stack.
The structure for the local « custom » folder changes too (for those who have some). In practice it means anything under '~/.CodeEnigma/ce-vm/ce-vm-custom/ce-vm' should be moved on level up at '~/.CodeEnigma/ce-vm/ce-vm-custom'
#### Porting existing projects
Replace the project Vagrantfile with the one from [https://github.com/codeenigma/ce-vm-model/blob/3.x/ce-vm/Vagrantfile](https://github.com/codeenigma/ce-vm-model/blob/3.x/ce-vm/Vagrantfile).

### 1.x > 2.x
There is no upgrade path from 1.x to 2.x and projects need to be individually ported.