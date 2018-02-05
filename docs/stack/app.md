This is the main component of the stack, combining the php cli, the webserver, etc.

## Vagrant

You can interact with it in vagrant commands by targeting it as "app-vm". Eg:

```vagrant up app-vm```

```vagrant ssh app-vm```

This is also the "primary" vagrant VM, which means commands that apply to a single VM will default to app-vm. See [vagrantup.com](https://www.vagrantup.com/docs/multi-machine/#controlling-multiple-machines) for more details on how vagrant interacts with multi machines.

## Network

It gets assigned the IP 192.168.56.2 and a DNS entry makes *.app-vm.codeenigma.com and point to it. You can access it at whatever.app-vm.codeenigma.com directly.

## Components

It bundles together:

- [NGINX](components/nginx.md) webserver
- [PHP](components/php.md)-FPM and associated utilities
    - Composer
    - PHP_CodeSniffer
    - PHP Mess Detector
    - Blackfire [optional]
    - XDebug [optional]
- [Postfix](components/postfix.md) mail server
- MkDocs documentation generator [optional]
- Node.js 4.x or 6.x [optional]
- [Selenium](components/selenium.md) testing framework [optional]

