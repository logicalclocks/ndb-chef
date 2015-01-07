name             "ndb"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "GPL 3.0"

description      "Installs/Configures NDB (MySQL Cluster)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          "1.0"

depends           "btsync"
depends           "kagent"

recipe            "ndb::install", "Installs MySQL Cluster binaries"

recipe            "ndb::mgmd", "Installs a MySQL Cluster management server (ndb_mgmd)"
recipe            "ndb::ndbd", "Installs a MySQL Cluster data node (ndbd)"
recipe            "ndb::mysqld", "Installs a MySQL Server connected to the MySQL Cluster (mysqld)"
recipe            "ndb::memcached", "Installs a memcached Server connected to the MySQL Cluster (memcached)"

recipe            "ndb::mgmd-purge", "Removes a MySQL Cluster management server (ndb_mgmd)"
recipe            "ndb::ndbd-purge", "Removes a MySQL Cluster data node (ndbd)"
recipe            "ndb::mysqld-purge", "Removes a MySQL Server connected to the MySQL Cluster (mysqld)"
recipe            "ndb::memcached-purge", "Removes a memcached Server connected to the MySQL Cluster (memcached)"

recipe            "ndb::btsync", "Installs MySQL Cluster binaries"

recipe            "ndb::purge", "Removes all data and all binaries related to a MySQL Cluster installation"

# internal recipes, not to be called from outside the cookbook
recipe            "ndb::hop", "Inifile processing for the kagent by ndb"

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
:default => 'kthfs'

attribute "mysql/password",
:display_name => "Mysql password for hop user",
:description => "Password for hop mysql user",
:type => 'string'

attribute "mysql/root/password",
:display_name => "MySQL server root password",
:description => "Password for the root mysql user",
:type => 'string',
:default => 'randomly generated'

attribute 'mgm/id',
:display_name => 'Mgm Server Id',
:description => 'Id of Mgm server being launched',
:type => 'string',
:default => '49'

attribute 'mysql/id',
:display_name => 'Mysql Id',
:description => 'Id of Mysql server being launched',
:type => 'string',
:default => '52'

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

attribute 'ndb/public_ips',
:display_name => 'Public ips for these nodes',
:description => 'Public ips of nodes in this group',
:type => 'array',
:default => '[10.0.2.15]'

attribute 'ndb/private_ips',
:display_name => 'Private ips for these nodes',
:description => 'Private ips of nodes in this group',
:type => 'array',
:default => '[10.0.2.15]'


attribute "ndb/mgmd/private_ips",
:display_name => "Ndb Mgm server Private IP addresses",
:description => "List of private IP addresses of ndb_mgmd processes",
:type => 'array',
:default => '[10.0.2.15]'

attribute "ndb/mgmd/public_ips",
:display_name => "Ndb Mgm server public IP addresses",
:description => "List of public IP addresses of ndb_mgmd processes",
:type => 'array',
:default => ""

attribute "ndb/ndbd/private_ips",
:display_name => "Data node private IP addresses",
:description => "List of private IP addresses of ndbd processes (data nodes)",
:type => 'array',
:default => '[10.0.2.15]'

attribute "ndb/ndbd/public_ips",
:display_name => "Data node public IP addresses",
:description => "List of public IP addresses of ndbd processes (data nodes)",
:type => 'array',
:default => ""

attribute "ndb/mysqld/private_ips",
:display_name => "MySQL Server private IP addresses",
:description => "List of private IP addresses of mysqld processes",
:type => 'array',
:default => '[10.0.2.15]'

attribute "ndb/mysqld/public_ips",
:display_name => "MySQL server public IP addresses",
:description => "List of public IP addresses of mysqld processes",
:type => 'array',
:default => ""

attribute "ndb/memcached/private_ips",
:display_name => "Memcached server private IP addresses",
:description => "List of private IP addresses of memcached processes",
:type => 'array',
:default => '[10.0.2.15]'

attribute "ndb/memcached/public_ips",
:display_name => "Memcached server public IP addresses",
:description => "List of public IP addresses of memcached processes",
:type => 'array',
:default => ""

attribute "kagent/enabled",
:display_name => "Install kagent",
:description =>  "Install kagent",
:type => 'string',
:default => "false"

