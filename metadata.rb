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

recipe            "ndb::btsync", "Installs MySQL Cluster binaries with BitTorrent (btsync)"

recipe            "ndb::purge", "Removes all data and all binaries related to a MySQL Cluster installation"



supports 'ubuntu', ">= 12.04"
supports 'rhel',   ">= 6.3"
supports 'centos',   ">= 6.3"
supports 'debian'

#
# Required Attributes
#

attribute "ndb/DataMemory",
          :display_name => "Data memory",
          :description => "Data memory for each MySQL Cluster Data Node",
          :type => 'string',
          :required => "required",
          :default => "80"

attribute "ndb/IndexMemory",
          :display_name => "Index memory",
          :description => "Index memory for each MySQL Cluster Data Node",
          :type => 'string',
          :calculated => true

attribute "memcached/mem_size",
          :display_name => "Memcached data memory size",
          :description => "Memcached data memory size",
          :type => 'string',
          :required => "required",
          :default => "80"

#
# Optional Attributes
#

attribute "ndb/version",
          :display_name => "Ndb version",
          :description =>  "MySQL Cluster Version",
          :required => "optional",
          :type => 'string'


attribute "ndb/user",
          :display_name => "Ndb username",
          :description => "User that runs ndb database",
          :type => 'string', 
          :required => "optional",         
          :default => 'root'

attribute "ndb/group",
          :display_name => "Ndb groupname",
          :description => "Group that runs ndb database",
          :type => 'string',
          :required => "optional",          
          :default => 'root'

attribute "mysql/user",
          :display_name => "Mysql username for hop",
          :description => "User that runs hop database",
          :required => "optional",
          :type => 'string',
          :default => 'mysql'

attribute "mysql/password",
          :display_name => "Mysql password for hop user",
          :description => "Password for hop mysql user",
          :calculated => true
          :type => 'string'

attribute "mysql/root/password",
          :display_name => "MySQL server root password",
          :description => "Password for the root mysql user",
          :type => 'string',
          :calculated => true

attribute "ndb/enabled",
          :display_name => "NDB enabled",
          :description => "Set to true if using MySQL Cluster, false for standalone MySQL Server",
          :type => 'string',
          :default => "true"

attribute "ndb/root_dir",
          :display_name => "Install directory for NDB",
          :description => "Install directory for MySQL Cluster data files",
          :type => 'string',
          :required => "optional",
          :default => "/var/lib/mysql-cluster"

attribute "mysql/base_dir",
          :display_name => "Install directory for MySQL Binaries",
          :description => "Install directory for MySQL Binaries",
          :type => 'string',
          :required => "optional",
          :default => "/usr/local"

attribute "ndb/mgm_server/port",
          :display_name => "Port used by Mgm servers",
          :description => "Port used by Mgm servers in MySQL Cluster",
          :type => 'string',
          :required => "optional",
          :default => ""

attribute "ndb/NoOfReplicas",
          :display_name => "Num Replicas",
          :description => "Num of replicas of the MySQL Cluster Data Nodes",
          :type => 'string',
          :required => "optional",
          :default => "2"

attribute "memcached/options",
          :display_name => "Memcached options",
          :description => "Memcached options",
          :type => 'string',
          :required => "optional",
          :default => ""

# attribute "btsync/ndb/seeder_secret",
# :display_name => "Ndb seeder's random secret key.",
# :description => "20 chars or more (normally 32 chars)",
# :type => 'string',
# :default => "AY27AAZKTKO3GONE6PBCZZRA6MKGRKBX2"

# attribute "btsync/ndb/leecher_secret",
# :display_name => "Ndb leecher's secret key.",
# :description => "Ndb's random secret (key) generated using the seeder's secret key. 20 chars or more (normally 32 chars)",
# :type => 'string',
# :default => "BTHKJKK4PIPIOJZ7GITF2SJ2IYDLSSJVY"

attribute "ndb/FragmentLogFileSize",
          :display_name => "FragmentLogFileSize",
          :description => "FragmentLogFileSize",
          :type => 'string',
          :default =>  "64M"

attribute "ndb/MaxNoOfAttributes",
          :display_name => "MaxNoOfAttributes",
          :description => "MaxNoOfAttributes",
          :type => 'string',
          :default =>  "60000"

attribute "ndb/MaxNoOfTables",
          :display_name => "MaxNoOfTables",
          :description => "MaxNoOfTables",
          :type => 'string',
          :default =>  "2024"

attribute "ndb/MaxNoOfOrderedIndexes",
          :display_name => "MaxNoOfOrderedIndexes",
          :description => "MaxNoOfOrderedIndexes",
          :type => 'string',
          :default =>  "256"

attribute "ndb/MaxNoOfUniqueHashIndexes",
          :display_name => "MaxNoOfUniqueHashIndexes",
          :description => "MaxNoOfUniqueHashIndexes",
          :type => 'string',
          :default =>  "128"

attribute "ndb/MaxDMLOperationsPerTransaction",
          :display_name => "MaxDMLOperationsPerTransaction",
          :description => "MaxDMLOperationsPerTransaction",
          :type => 'string',
          :default =>  "128"

attribute "ndb/TransactionBufferMemory",
          :display_name => "TransactionBufferMemory",
          :description => "TransactionBufferMemory",
          :type => 'string',
          :default =>  "1M"

attribute "ndb/MaxParallelScansPerFragment",
          :display_name => "MaxParallelScansPerFragment",
          :description => "MaxParallelScansPerFragment",
          :type => 'string',
          :default =>  "256"

attribute "ndb/MaxDiskWriteSpeed",
          :display_name => "MaxDiskWriteSpeed",
          :description => "MaxDiskWriteSpeed",
          :type => 'string',
          :default =>  "20M"

attribute "ndb/MaxDiskWriteSpeedOtherNodeRestart",
          :display_name => "MaxDiskWriteSpeedOtherNodeRestart",
          :description => "MaxDiskWriteSpeedOtherNodeRestart",
          :type => 'string',
          :default =>  "50M"

attribute "ndb/MaxDiskWriteSpeedOwnRestart",
          :display_name => "MaxDiskWriteSpeedOwnRestart",
          :description => "MaxDiskWriteSpeedOwnRestart",
          :type => 'string',
          :default =>  "200M"

attribute "ndb/MinDiskWriteSpeed",
          :display_name => "MinDiskWriteSpeed",
          :description => "MinDiskWriteSpeed",
          :type => 'string',
          :default =>  "5M"

attribute "ndb/DiskSyncSize",
          :display_name => "DiskSyncSize",
          :description => "DiskSyncSize",
          :type => 'string',
          :default =>  "4M"

attribute "ndb/RedoBuffer",
          :display_name => "RedoBuffer",
          :description => "RedoBuffer",
          :type => 'string',
          :default =>  "32M"

attribute "ndb/LongMessageBuffer",
          :display_name => "LongMessageBuffer",
          :description => "LongMessageBuffer",
          :type => 'string',
          :default =>  "64M"

attribute "ndb/TransactionInactiveTimeout",
          :display_name => "TransactionInactiveTimeout",
          :description => "TransactionInactiveTimeout",
          :type => 'string',
          :default =>  "10000"

attribute "ndb/TransactionDeadlockDetectionTimeout",
          :display_name => "TransactionDeadlockDetectionTimeout",
          :description => "TransactionDeadlockDetectionTimeout",
          :type => 'string',
          :default =>  "10000"

attribute "ndb/LockPagesInMainMemory",
          :display_name => "LockPagesInMainMemory",
          :description => "LockPagesInMainMemory",
          :type => 'string',
          :default =>  "1"

attribute "ndb/RealTimeScheduler",
          :display_name => "RealTimeScheduler",
          :description => "RealTimeScheduler",
          :type => 'string',
          :default =>  "0"

attribute "ndb/SchedulerSpinTimer",
          :display_name => "SchedulerSpinTimer",
          :description => "SchedulerSpinTimer",
          :type => 'string',
          :default =>  "0"

attribute "ndb/BuildIndexThreads",
          :display_name => "BuildIndexThreads",
          :description => "BuildIndexThreads",
          :type => 'string',
          :default =>  "10"

attribute "ndb/CompressedLCP",
          :display_name => "CompressedLCP",
          :description => "CompressedLCP",
          :type => 'string',
          :default =>  "0"

attribute "ndb/CompressedBackup",
          :display_name => "CompressedBackup",
          :description => "CompressedBackup",
          :type => 'string',
          :default =>  "1"

attribute "ndb/BackupMaxWriteSize",
          :display_name => "BackupMaxWriteSize",
          :description => "BackupMaxWriteSize",
          :type => 'string',
          :default =>  "1M"

attribute "ndb/BackupLogBufferSize",
          :display_name => "BackupLogBufferSize",
          :description => "BackupLogBufferSize",
          :type => 'string',
          :default =>  "4M"

attribute "ndb/BackupDataBufferSize",
          :display_name => "BackupDataBufferSize",
          :description => "BackupDataBufferSize",
          :type => 'string',
          :default =>  "16M"

attribute "ndb/BackupMemory",
          :display_name => "BackupMemory",
          :description => "BackupMemory",
          :type => 'string',
          :default =>  "20M"

attribute "ndb/MaxAllocate",
          :display_name => "MaxAllocate",
          :description => "MaxAllocate",
          :type => 'string',
          :default =>  "32M"

attribute "ndb/DefaultHashMapSize",
          :display_name => "DefaultHashMapSize",
          :description => "DefaultHashMapSize",
          :type => 'string',
          :default =>  "3840"

attribute "ndb/ODirect",
          :display_name => "ODirect",
          :description => "ODirect",
          :type => 'string',
          :default =>  "0"

attribute "ndb/SendBufferMemory",
          :display_name => "SendBufferMemory",
          :description => "SendBufferMemory",
          :type => 'string',
          :default =>  "2M"

attribute "ndb/ReceiveBufferMemory",
          :display_name => "ReceiveBufferMemory",
          :description => "ReceiveBufferMemory",
          :type => 'string',
          :default =>  "2M"

attribute "kagent/enabled",
          :display_name => "Install kagent",
          :description =>  "Install kagent",
          :type => 'string',
          :required => "optional",
          :default => "false"

