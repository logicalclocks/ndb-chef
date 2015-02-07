name             "ndb"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "GPL 3.0"

description      "Installs/Configures NDB (MySQL Cluster)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          "1.0"

depends           "kagent"
depends           "btsync"

recipe            "ndb::install", "Installs MySQL Cluster binaries"

recipe            "ndb::mgmd", "Installs a MySQL Cluster management server (ndb_mgmd)"
recipe            "ndb::ndbd", "Installs a MySQL Cluster data node (ndbd)"
recipe            "ndb::mysqld", "Installs a MySQL Server connected to the MySQL Cluster (mysqld)"
recipe            "ndb::memcached", "Installs a memcached Server connected to the MySQL Cluster (memcached)"

recipe            "ndb::mgmd-purge", "Removes a MySQL Cluster management server (ndb_mgmd)"
recipe            "ndb::ndbd-purge", "Removes a MySQL Cluster data node (ndbd)"
recipe            "ndb::mysqld-purge", "Removes a MySQL Server connected to the MySQL Cluster (mysqld)"
recipe            "ndb::memcached-purge", "Removes a memcached Server connected to the MySQL Cluster (memcached)"

#recipe            "ndb::btsync", "Installs MySQL Cluster binaries"

recipe            "ndb::purge", "Removes all data and all binaries related to a MySQL Cluster installation"



supports 'ubuntu', ">= 12.04"
supports 'rhel',   ">= 6.3"
supports 'centos',   ">= 6.3"
supports 'debian'

attribute "ndb/enabled",
:display_name => "NDB enabled",
:description => "Set to true if using MySQL Cluster, false for standalone MySQL Server",
:type => 'string',
:default => "true"

attribute "ndb/root_dir",
:display_name => "Install directory for NDB",
:description => "Install directory for MySQL Cluster data files",
:type => 'string',
:default => "/var/lib/mysql-cluster"

attribute "mysql/base_dir",
:display_name => "Install directory for MySQL Binaries",
:description => "Install directory for MySQL Binaries",
:type => 'string',
:default => "/usr/local"

attribute "ndb/data_memory",
:display_name => "Data memory",
:description => "Data memory for each MySQL Cluster Data Node",
:type => 'string',
:default => "80"

attribute "ndb/index_memory",
:display_name => "Index memory",
:description => "Index memory for each MySQL Cluster Data Node",
:type => 'string',
:default => "20"

attribute "ndb/num_replicas",
:display_name => "Num Replicas",
:description => "Num of replicas of the MySQL Cluster Data Nodes",
:type => 'string',
:default => "2"

attribute "ndb/mgm_server/port",
:display_name => "Port used by Mgm servers",
:description => "Port used by Mgm servers in MySQL Cluster",
:type => 'string',
:default => ""

attribute "memcached/mem_size",
:display_name => "Memcached data memory size",
:description => "Memcached data memory size",
:type => 'string',
:default => "80"

attribute "memcached/options",
:display_name => "Memcached options",
:description => "Memcached options",
:type => 'string',
:default => ""

attribute "mysql/user",
:display_name => "Mysql username for hop",
:description => "User that runs hop database",
:type => 'string',
:default => 'mysql'

attribute "mysql/password",
:display_name => "Mysql password for hop user",
:description => "Password for hop mysql user",
:type => 'string'

attribute "mysql/root/password",
:display_name => "MySQL server root password",
:description => "Password for the root mysql user",
:type => 'string',
:default => 'randomly generated'

attribute "btsync/ndb/seeder_ip",
:display_name => "Bootstrap node IP address",
:description => "IP address of the btsync seeder for NDB",
:type => 'string',
:default => ""

attribute "btsync/ndb/leechers",
:display_name => "NDB peer IP addresses",
:description => "List of IP addresses for btsync leechers downloading NDB",
:type => 'array',
:default => ""

attribute "btsync/ndb/seeder_secret",
:display_name => "Ndb seeder's random secret key.",
:description => "20 chars or more (normally 32 chars)",
:type => 'string',
:default => "AY27AAZKTKO3GONE6PBCZZRA6MKGRKBX2"

attribute "btsync/ndb/leecher_secret",
:display_name => "Ndb leecher's secret key.",
:description => "Ndb's random secret (key) generated using the seeder's secret key. 20 chars or more (normally 32 chars)",
:type => 'string',
:default => "BTHKJKK4PIPIOJZ7GITF2SJ2IYDLSSJVY"

attribute "kagent/enabled",
:display_name => "Install kagent",
:description =>  "Install kagent",
:type => 'string',
:default => "false"

attribute "ndb/version",
:display_name => "Ndb version",
:description =>  "MySQL Cluster Version",
:type => 'string'

attribute "ndb/user",
:display_name => "Ndb username",
:description => "User that runs ndb database",
:type => 'string',
:default => 'root'

attribute "ndb/group",
:display_name => "Ndb groupname",
:description => "Group that runs ndb database",
:type => 'string',
:default => 'root'
