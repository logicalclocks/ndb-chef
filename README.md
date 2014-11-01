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
* Ubuntu 10.04-12.04
* centos 6.5


Usage
--------

1. install gems needed to test chef recipes
bundle install

2. Test recipe syntax and code-style
bundle exec foodcritic .

3. run kitchen to test recipes
kitchen test

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
