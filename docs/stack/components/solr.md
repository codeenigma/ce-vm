
[http://lucene.apache.org/solr](http://lucene.apache.org/solr)

## Base setup
Installation of Apache Solr is triggered by the ```solr``` variable in your config.yml file (yes/no value).
By default, Solr 4.6.1 will be created with a "default" core, and the minimal
configuration shipped in the examples modules. It uses Tomcat7 as server, listening on port 8080.

The admin interface will be available at http://db-vm.codeenigma.com:8080/solr
and the default core at http://db-vm.codeenigma.com:8080/solr/default (eg http://db-vm.codeenigma.com:8080/solr/default/select?q=*%3A*&wt=json&indent=true).

### Configuring cores
You can define as many cores as needed, using the ```solr_cores``` variables. 
The actual configuration for each cores will be fetched from a folder named after the core name,
placed under the ```solr_conf_path```defined in config.yml, which is relative to your project root.

#### Example
For an "example" Drupal 7 project using 2 cores, both with [search_api_solr](https://www.drupal.org/project/search_api_solr):
 your project config file would contain:

```
  # Enable Solr
  solr: yes
  # The path is relative to you project root.
  solr_conf_path: ce-vm/solr
  solr_cores:
    - drupal1
    - anothercore
```
And you would copy the configuration provided by the module [solr-conf/4.x](http://cgit.drupalcode.org/search_api_solr/tree/solr-conf/4.x?h=7.x-1.x) to 
both "example/ce-vm/solr/drupal1" and "example/ce-vm/solr/anothercore"

After a ```vagrant provision```, the config for them would be:
- http://db-vm.codeenigma.com:8080/solr/drupal1
- http://db-vm.codeenigma.com:8080/solr/anothercore