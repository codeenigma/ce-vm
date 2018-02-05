
Once you have [installed the requirements](install.md), next step is to create a skeleton for your project at [http://ce-vm.codeenigma.net](http://ce-vm.codeenigma.net)

## Directory structure and basic usage

Depending on your platform and the tools you used to extract the generated archive, you might end up with and extra folder layer, which you can discard.
A fresh "myproject" project ready to be used should have the following layout:
```
myproject // This is the root of the project
  README.md
  ce-vm // This is the configuration and local tools for ce-vm
    config.yml
    Vagranfile
    ...
```

This is the skeleton, ready to be instanciated with `cd myproject/ce-vm && vagrant up`. 

If that's the first time you ever use ce-vm, the process will setup the base "upstream" repo at ~/.CodeEnigma/ce-vm/ce-vm-upstream and instruct you to repeat the same `vagrant up` command.
At the end of the process, your boilerplate structure should have been populated. The actual content will vary depending on the type of project and other options, but should look similar to:

```
myproject // This is the root of the project
  README.md
  ce-vm // This is the configuration and local tools for ce-vm
  www // This is your webroot, mapped to http://myproject.app-vm.codeenigma.com
  docs // Additional folders and files may appear (drush, composer.json, ...)
```

Once the process is finished just open [http://app-vm.codeenigma.com](http://app-vm.codeenigma.com) in your browser.

## Vagrant

While everything runs in Docker containers, you should not interact with them using docker commands directly, but instead use the Vagrant layer. 

This is because a lot of configuration is done in Vagrant (networking, YAML parsing, coordinating the containers, etc) and then passed over to Docker. If you are familiar with "docker-compose", think of it as an equivalent, just more powerful.

The only commands you need to know for a start are:

- `vagrant up`: spin up your projects containers, (and provision/configure them the first time)
- `vagrant halt`: power off running containers
- `vagrant ssh`: ssh into the main "app-vm" container
- `vagrant provision`: re-apply the Ansible configuration to running containers
- `vagrant destroy`: destroy all of your project's containers

*You can also target a given container only, by specifying the target "machine": `vagrant halt app-vm, vagrant ssh db-vm, ...` see [vagrantup.com](https://www.vagrantup.com/docs/multi-machine/#controlling-multiple-machines)*



# Shared folders

The project's root, *myproject* in this example, will be mounted as */vagrant* on the guest and anything in there can be edited indifferently from both the guest and the host.

*There is also an additional mount of ~/.CodeEnigma to /home/vagrant/.CodeEnigma, mostly reserved for provisioning and internal use*

The various options available for the way those shared folders play a crucial role in the performance ov your setup, and are also the major cause of issues.