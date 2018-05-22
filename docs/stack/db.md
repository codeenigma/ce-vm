This is the database component of the stack.

## Vagrant

You can interact with it in vagrant commands by targeting it as "db-vm". Eg:

```vagrant up db-vm```

```vagrant ssh db-vm```

See [vagrantup.com](https://www.vagrantup.com/docs/multi-machine/#controlling-multiple-machines) for more details on how vagrant interacts with multi machines.

## Network

It gets assigned the IP 192.168.56.3 and a DNS entry makes *.db-vm.codeenigma.com and point to it. You can access it at db-vm.codeenigma.com directly, or at {project_name}-db from within the "App" instance.

## Components

It bundles together:

- Percona server (MySQL)
- [Postfix](components/postfix.md) mail server
- memcached [optional]
- [Solr](components/solr.md) search platform [optional]
