name             "ndb"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "AGPL v3"
description      "Installs/Configures NDB (MySQL Cluster)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.0.0"
source_url       "https://github.com/logicalclocks/ndb-chef"
issues_url       "https://github.com/logicalclocks/ndb-chef/issues"

depends           "kagent"
depends           "consul"
depends           "ulimit"

recipe            "ndb::install", "Installs MySQL Cluster binaries"

recipe            "ndb::mgmd", "Installs a MySQL Cluster management server (ndb_mgmd)"
recipe            "ndb::ndbd", "Installs a MySQL Cluster data node (ndbd)"
recipe            "ndb::mysqld", "Installs a MySQL Server connected to the MySQL Cluster (mysqld)"
recipe            "ndb::mysqld_tls", "Configure TLS for MySQL servers using host certificates"

recipe            "ndb::purge", "Removes all data and all binaries related to a MySQL Cluster installation"

supports 'ubuntu', ">= 14.04"
supports 'rhel',   ">= 7.0"
supports 'centos', ">= 7.0"

#
# Required Attributes
#

attribute "ndb/url",
          :description => "Download URL for MySQL Cluster binaries",
          :type => 'string'

attribute "ndb/MaxNoOfExecutionThreads",
          :description => "Number of execution threads for MySQL Cluster",
          :type => 'string'

attribute "ndb/DataMemory",
          :description => "Data memory for each MySQL Cluster Data Node",
          :type => 'string',
          :required => "required"

attribute "ndb/version",
          :description =>  "MySQL Cluster Version",
          :type => 'string'

attribute "ndb/user",
          :description => "User that runs ndb database",
          :type => 'string'

attribute "ndb/group",
          :description => "Group that runs ndb database",
          :type => 'string'

attribute "ndb/user-home",
          :description => "Home directory of ndb user",
          :type => 'string'

attribute "ndb/BackupDataDir",
          :description => "Directory to store mysql cluster backups in",
          :type => 'string'

attribute "ndb/remote_backup_host",
          :description => "Hostname of the machine where the backups will be stored",
          :type => 'string'

attribute "ndb/remote_backup_user",
          :description => "User on the remote backup machine. SSH access should be configured",
          :type => 'string'

attribute "ndb/remote_backup_dir",
          :description => "Directory on the remote backup machine that the archives will be stored",
          :type => 'string'

attribute "ndb/local_backup_dir",
          :description => "Directory on the local MGM machine where backups will temporarily be stored",
          :type => 'string'

attribute "ndb/ndbd_backup_retention",
          :description => "How many n*24 hours are the backup files in NDB Data Nodes going to stay until they are removed",
          :type => 'string'

attribute "ndb/diskdata_dir",
          :description => "Directory on the NDBD machines where the on-disk columns will be stored. This should be a NVMe disk for best performance.",
          :type => 'string'

attribute "ndb/DiskPageBufferEntries",
          :description => "Number of page entries (page references) to allocate.",
          :type => 'string'

attribute "ndb/DiskIOThreadPool",
          :description => "Default is (2). Increase for higher throughput.",
          :type => 'string'

attribute "ndb/SharedGlobalMemory",
          :description => "Default is 128M, increase to 512M for higher throughput.",
          :type => 'string'

attribute "ndb/DiskPageBufferMemory",
          :description => "Default is 64M, increase to 512M for higher throughput.",
          :type => 'string'

attribute "mysql/user",
          :description => "User that runs mysql server",
          :required => "required",
          :type => 'string'

attribute "mysql/password",
          :description => "Password for hop mysql user",
          :required => "required",
          :type => 'string'

attribute "mysql/initialize",
          :description => "Initialize the MySQL Servers (Default: true)",
          :type => "string"

attribute "mysql/dir",
          :description => "Directory in which to install MySQL Binaries",
          :type => 'string'

attribute "mysql/localhost",
          :description => "MySQL server binds to localhost (not a public/private network interface)",
          :type => 'string'

attribute "mysql/replication_enabled",
          :description => "Enable replication for the mysql server",
          :type => 'string'

attribute "mysql/onlinefs",
          :description => "Set true to use this MySQL server as online feature store (default: true)",
          :type => 'string'

attribute "mysql/tls",
          :description => "Enable TLS/SSL for the mysql server",
          :type => 'string'

attribute "ndb/wait_startup",
          :description => "Max amount of time a MySQL server should wait for the ndb nodes to be up",
          :type => 'string'

attribute "ndb/mgm_server/port",
          :description => "Port used by Mgm servers in MySQL Cluster",
          :type => 'string'

attribute "ndb/NoOfReplicas",
          :description => "Num of replicas of the MySQL Cluster Data Nodes",
          :type => 'string'

attribute "ndb/FragmentLogFileSize",
          :description => "FragmentLogFileSize",
          :type => 'string'

attribute "ndb/MaxNoOfAttributes",
          :description => "MaxNoOfAttributes",
          :type => 'string'

attribute "ndb/MaxNoOfConcurrentIndexOperations",
          :description => "Increase for higher throughput at the cost of more memory",
          :type => 'string'

attribute "ndb/MaxNoOfConcurrentScans",
          :description => "Increase for higher throughput at the cost of more memory",
          :type => 'string'

attribute "ndb/MaxNoOfConcurrentOperations",
          :description => "Increase for higher throughput at the cost of more memory",
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

attribute "ndb/MaxFKBuildBatchSize",
          :description => "MaxFKBuildBatchSize",
          :type => 'string'

attribute "ndb/MaxReorgBuildBatchSize",
          :description => "MaxReorgBuildBatchSize",
          :type => 'string'

attribute "ndb/EnablePartialLcp",
          :description => "EnablePartialLcp",
          :type => 'string'

attribute "ndb/RecoveryWork",
          :description => "RecoveryWork",
          :type => 'string'

attribute "ndb/InsertRecoveryWork",
          :description => "InsertRecoveryWork",
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

attribute "ndb/NoOfFragmentLogFiles",
          :description =>  "Number of fragment logfiles for writing LCPS.",
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

attribute "ndb/cron_backup",
          :description =>  "Default is 'false'. To turn on, set to 'true'",
          :type => 'string'

attribute "ndb/backup_frequency",
          :description =>  "Options are 'daily', 'weekly'. Default is 'daily'",
          :type => 'string'

attribute "ndb/backup_time",
          :description =>  "Time in 24-hour clock of when to make the regular backup. Default: 03:00 (in the morning)",
          :type => 'string'

attribute "ndb/MaxNoOfConcurrentTransactions",
          :description =>  "Maximum number of concurrent transactions (higher consumes more memory)",
          :type => 'string'

attribute "ndb/mgmd/private_ips",
          :description =>  "Ips for ndb_mgmds",
          :type => 'array'

attribute "ndb/mysqld/private_ips",
          :description =>  "Ips for mysql servers",
          :type => 'array'

attribute "ndb/ndbd/private_ips",
          :description =>  "Ips for ndb data nodes",
          :type => 'array'

attribute "ndb/ndbd/ips_ids",
          :description =>  "The format should be ['ip1:id1', 'ip2:id2', ...] for the ndbd section in the config.ini file. If no value is supplied, one will be assigned by default.",
          :type => 'array'

attribute "ndb/ndbd/systemctl_timeout_sec",
          :description =>  "Systemctl start timeout for datanode in seconds",
          :type => 'string'

attribute "ndb/mysqld/ips_ids",
          :description =>  "The format should be ['ip1:id1', 'ip2:id2', ...] for the mysql section in the config.ini file. If no value is supplied, one will be assigned by default.",
          :type => 'array'

attribute "ndb/EnableRedoControl",
          :description => "Control disk read/write speeds automatically for LCPs (default '1', to turn off - set to '0'",
          :type => 'string'

attribute "ndb/mgmd/private_ips_domainIds",
          :description => "private_ips to LocationDomainIds for ndb_mgmds",
          :type => 'array'

attribute "ndb/ndbd/private_ips_domainIds",
          :description => "private_ips to LocationDomainIds for ndb data nodes",
          :type => 'hash'

attribute "ndb/mysqld/private_ips_domainIds",
          :description => "private_ips to LocationDomainIds mapping for mysql servers",
          :type => 'hash'

attribute "ndb/ndbapi/private_ips_domainIds",
          :description => "LocationDomainIds for ndb api nodes (namenodes)",
          :type => 'hash'

attribute "ndb/mysql_socket",
          :description => "Location of the MySQL unix socket",
          :type => "string"

attribute "ndb/mysql_port",
          :description => "Port on which the MySQL server binds to",
          :type => "string"

attribute "services/enabled",
          :description => "Default 'false'. Set to 'true' to enable daemon services, so that they are started on a host restart.",
          :type => "string"

attribute "ndb/nvme/devices",
          :description => "Array of strings for NVMe devices (e.g., ['/dev/nvme0n1', '/dev/nvme0n2']) to use for the on on-disk data.",
          :type => "array"

attribute "ndb/nvme/format",
          :description => "Default 'false'. Set to 'true' to format the NVMe disks specified in ndb/nvme/disks.",
          :type => "string"

attribute "ndb/nvme/logfile_size",
          :description => "Amount of extra disk space to use on the NVMe disks for NDB.",
          :type => "string"

attribute "ndb/nvme/undofile_size",
          :description => "Amount of extra disk space to use for log files on the NVMe disks for NDB.",
          :type => "string"

attribute "ndb/num_ndb_slots_per_client",
          :description => "Number of NDB connection slots per api node",
          :type => "string"

attribute "ndb/num_ndb_slots_per_mysqld",
          :description => "Number of NDB connection slots per mysqld node",
          :type => "string"

attribute "ndb/num_ndb_open_slots",
          :description => "Number of slots open for new clients to connect.",
          :type => "string"
