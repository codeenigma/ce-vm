#App VM

This is the webserver component of the stack.

## Vagrant

You can interact with it in vagrant commands by targeting it as "app-vm". Eg:

```vagrant up app-vm```

```vagrant ssh app-vm```

This is also the "primary" vagrant VM, which means commands that apply to a single VM will default to app-vm. See [vagrantup.com](https://www.vagrantup.com/docs/multi-machine/#controlling-multiple-machines) for more details on how vagrant interacts with multi machines.

## Network

It gets assigned the IP 192.168.56.2 which is accessible from your host when using VirtualBox. 
A DNS entry makes app-vm.codeenigma.com and any subdomain point to it, meaning you can access it at whatever.app-vm.codeenigma.com directly. 

When using Docker, it is only accessible through port forwarding, which means you need to add an host entry pointing to 127.0.0.1 to access it through a domain name.

## Components

It bundles together:

- [NGINX](../components/nginx.md) webserver
- [PHP](../components/php.md)-FPM and associated utilities
    - Composer
    - PHP_CodeSniffer
    - PHP Mess Detector
    - XDebug (optional)
    - Blackfire (optional)
- Node.js 4.x or 6.x (optional)
- MkDocs documentation generator (optional)
- Postfix mail server

