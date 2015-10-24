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
          :description => "Data memory for each MySQL Cluster Data Node",
          :type => 'string',
          :required => "required"

attribute "ndb/IndexMemory",
          :description => "Index memory for each MySQL Cluster Data Node",
          :type => 'string'

attribute "memcached/mem_size",
          :description => "Memcached data memory size",
          :type => 'string'

attribute "ndb/version",
          :description =>  "MySQL Cluster Version",
          :type => 'string'

attribute "ndb/user",
          :description => "User that runs ndb database",
          :type => 'string'

attribute "ndb/group",
          :description => "Group that runs ndb database",
          :type => 'string'

attribute "mysql/user",
          :description => "User that runs mysql server",
          :required => "required",
          :type => 'string'

attribute "mysql/password",
          :description => "Password for hop mysql user",
          :required => "required",
          :type => 'string'
#          :calculated => true

# attribute "mysql/root/password",
#           :display_name => "MySQL server root password",
#           :description => "Password for the root mysql user",
#           :type => 'string',
#           :calculated => true

#attribute "ndb/enabled",
#          :description => "Set to true if using MySQL Cluster, false for standalone MySQL Server",
#          :type => 'string'

attribute "mysql/dir",
          :description => "Directory in which to install MySQL Binaries",
          :type => 'string'

attribute "ndb/mgm_server/port",
          :description => "Port used by Mgm servers in MySQL Cluster",
          :type => 'string'

attribute "ndb/NoOfReplicas",
          :description => "Num of replicas of the MySQL Cluster Data Nodes",
          :type => 'string'

#attribute "memcached/options",
#          :description => "Memcached options",
#          :type => 'string'

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
          :description => "FragmentLogFileSize",
          :type => 'string'

attribute "ndb/MaxNoOfAttributes",
          :description => "MaxNoOfAttributes",
          :type => 'string'

attribute "ndb/MaxNoOfTables",
          :description => "MaxNoOfTables",
          :type => 'string'

attribute "ndb/MaxNoOfOrderedIndexes",
          :description => "MaxNoOfOrderedIndexes",
          :type => 'string'

attribute "ndb/MaxNoOfUniqueHashIndexes",
          :description => "MaxNoOfUniqueHashIndexes",
          :type => 'string'

attribute "ndb/MaxDMLOperationsPerTransaction",
          :description => "MaxDMLOperationsPerTransaction",
          :type => 'string'

attribute "ndb/TransactionBufferMemory",
          :description => "TransactionBufferMemory",
          :type => 'string'

attribute "ndb/MaxParallelScansPerFragment",
          :description => "MaxParallelScansPerFragment",
          :type => 'string'

attribute "ndb/MaxDiskWriteSpeed",
          :description => "MaxDiskWriteSpeed",
          :type => 'string'

attribute "ndb/MaxDiskWriteSpeedOtherNodeRestart",
          :description => "MaxDiskWriteSpeedOtherNodeRestart",
          :type => 'string'

attribute "ndb/MaxDiskWriteSpeedOwnRestart",
          :description => "MaxDiskWriteSpeedOwnRestart",
          :type => 'string'

attribute "ndb/MinDiskWriteSpeed",
          :description => "MinDiskWriteSpeed",
          :type => 'string'

attribute "ndb/DiskSyncSize",
          :description => "DiskSyncSize",
          :type => 'string'

attribute "ndb/RedoBuffer",
          :description => "RedoBuffer",
          :type => 'string'

attribute "ndb/LongMessageBuffer",
          :description => "LongMessageBuffer",
          :type => 'string'

attribute "ndb/TransactionInactiveTimeout",
          :description => "TransactionInactiveTimeout",
          :type => 'string'

attribute "ndb/TransactionDeadlockDetectionTimeout",
          :description => "TransactionDeadlockDetectionTimeout",
          :type => 'string'

attribute "ndb/LockPagesInMainMemory",
          :description => "LockPagesInMainMemory",
          :type => 'string'

attribute "ndb/RealTimeScheduler",
          :description => "RealTimeScheduler",
          :type => 'string'

attribute "ndb/SchedulerSpinTimer",
          :description => "SchedulerSpinTimer",
          :type => 'string'

attribute "ndb/BuildIndexThreads",
          :description => "BuildIndexThreads",
          :type => 'string'

attribute "ndb/CompressedLCP",
          :description => "CompressedLCP",
          :type => 'string'

attribute "ndb/CompressedBackup",
          :description => "CompressedBackup",
          :type => 'string'

attribute "ndb/BackupMaxWriteSize",
          :description => "BackupMaxWriteSize",
          :type => 'string'

attribute "ndb/BackupLogBufferSize",
          :description => "BackupLogBufferSize",
          :type => 'string'

attribute "ndb/BackupDataBufferSize",
          :description => "BackupDataBufferSize",
          :type => 'string'

attribute "ndb/BackupMemory",
          :description => "BackupMemory",
          :type => 'string'

attribute "ndb/MaxAllocate",
          :description => "MaxAllocate",
          :type => 'string'

attribute "ndb/DefaultHashMapSize",
          :description => "DefaultHashMapSize",
          :type => 'string'

attribute "ndb/ODirect",
          :description => "ODirect",
          :type => 'string'

attribute "ndb/TotalSendBufferMemory",
          :description => "TotalSendBufferMemory in MBs",
          :type => 'string'

attribute "ndb/ReservedSendBufferMemory",
          :description => "ReservedSendBufferMemory in MBs - for exclusive NDBD<->NDBD connections, not API<->NDBDs.",
          :type => 'string'

attribute "ndb/OverloadLimit",
          :description => "Overload for Send/Recv TCP Buffers in MBs",
          :type => 'string'

attribute "kagent/enabled",
          :description =>  "Install kagent",
          :type => 'string',
          :required => "optional"

attribute "ndb/NoOfFragmentLogParts",
          :description =>  "One per ldm thread. Valid values: 4, 8, 16. Should match the number of CPUs in ThreadConfig's ldm threads.",
          :type => 'string'

attribute "ndb/bind_cpus",
          :description =>  "Isolate interrupts from cpus, turn off balance_irqs",
          :type => 'string'

attribute "ndb/TcpBind_INADDR_ANY",
          :description =>  "Set to TRUE so that any IP addr can be used on any node. Default is FALSE.",
          :type => 'string'

attribute "ndb/aws_enhanced_networking",
          :description =>  "Set to true if you want the ixgbevf module to be installed that is needed for AWS enhanced networking.",
          :type => 'string'

attribute "ndb/interrupts_isolated_to_single_cpu",
          :description =>  "Set to true if you want to setup your linux kernal to handle interrupts on a single CPU.",
          :type => 'string'

attribute "ndb/ThreadConfig",
          :description => "Decide which threads bind to which cores: Threadconfig=main={cpubind=0},ldm={count=8,cpubind=1,2,3,4,13,14,15,16},io={count=4,cpubind=5,6,17,18},rep={cpubind=7},recv={count=2,cpubind=8,19}k",
          :type => 'string'

attribute "ndb/dir",
          :description =>  "Directory in which to install mysql-cluster",
          :type => 'string'
