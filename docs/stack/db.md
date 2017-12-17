This is the database component of the stack.

## Vagrant

You can interact with it in vagrant commands by targeting it as "db-vm". Eg:

```vagrant up db-vm```

```vagrant ssh db-vm```

See [vagrantup.com](https://www.vagrantup.com/docs/multi-machine/#controlling-multiple-machines) for more details on how vagrant interacts with multi machines.

## Network

It gets assigned the IP 192.168.56.3 which is accessible from your host when using VirtualBox. 
A DNS entry makes db-vm.codeenigma.com and any subdomain point to it, meaning you can access it at whatever.db-vm.codeenigma.com directly. 

When using Docker, it is only accessible through port forwarding, which means you need to add an host entry pointing to 127.0.0.1 to access it through a domain name.

## Components

It bundles together:

- Percona server (MySQL)
- [Postfix](components/postfix.md) mail server
- memcached [optional]
- [Solr](components/solr.md) search platform [optional]