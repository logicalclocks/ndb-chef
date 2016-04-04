Description
===========

Installs and configures a MySQL Cluster, including the management server(s), data nodes, and MySQL Server(s).

Requirements
============
Chef 0.11+.

Platform
--------
* Ubuntu, centos


Tested on:
* Ubuntu 12.04-14.04
* centos 7.0+


Usage
--------

1. install gems needed to test chef recipes
bundle install

2. Test recipe syntax and code-style
bundle exec foodcritic .

3. run kitchen to test recipes
./kitchen.sh

###Chef-solo usage
On a node that provides both a Management Server and a MySQL Server, use both the mgmd and mysqld recipes:

    { "run_list": ["recipe[ndb::install]", "recipe[ndb::mgmd]", "recipe[ndb::mysqld]" }

This will install and start both a ndb_mgmd and a mysqld daemon on both nodes.

On a node that will provide a data node, run:
    { "run_list": ["recipe[ndb::install]", "recipe[ndb::ndbd]" }

This will install a data node on the host, that is, an ndbd process.

You can override attributes in your node or role.
For example, on an Ubuntu system:
    {
      "mysql": {
        "password": "secret"
      }
    }

###Karamel usage
This cookbook is karamelized (www.karamel.io). 
You can launch a MySQL Cluster using the following yml file. It will create 5 VMs on EC2, and install ndb datanodes on 4 VMs, and a management server, a MySQL Server, and a Memcached server on 1 VM.

name: MySqlCluster                                                             

cookbooks:                                                                      
  ndb:
    github: "hopshadoop/ndb-chef"
    version: "v0.1"
    
groups: 
  datanodes:
    size: 4 
    recipes: 
        - ndb::ndbd
  server:
    size: 1 
    recipes: 
        - ndb::mysqld
        - ndb::memcached
        - ndb::mgmd



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
