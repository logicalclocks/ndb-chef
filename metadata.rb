name             "ndb"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "AGPL v3"
description      "Installs/Configures NDB (MySQL Cluster)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.4.0"
source_url       "https://github.com/logicalclocks/ndb-chef"
issues_url       "https://github.com/logicalclocks/ndb-chef/issues"

depends           "kagent"
depends           "consul"

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

attribute "ndb/majorVersion",
          :description => "RonDB major version",
          :type => 'string'

attribute "ndb/minorVersion",
          :description => "RonDB minor version",
          :type => 'string'

attribute "ndb/patchVersion",
          :description => "RonDB patch version",
          :type => 'string'

attribute "ndb/url",
          :description => "Download URL for MySQL Cluster binaries",
          :type => 'string'

attribute "ndb/MaxNoOfExecutionThreads",
          :description => "Number of execution threads for MySQL Cluster",
          :type => 'string'

attribute "ndb/configuration/type",
          :description =>  "Control RonDB configuration. auto | manual Default: auto",
          :type => 'string'

attribute "ndb/configuration/profile",
          :description =>  "Predefined configurations. unlimited | tiny Default: unlimited",
          :type => 'string'

attribute "ndb/replication/cluster-id",
          :description =>  "Cluster ID used to compute monotonicaly increasing MySQL server-id. In Global Replication these IDs need to be globally unique. Default: 100",
          :type => 'string'

attribute "ndb/replication/primary-cluster-id",
          :description =>  "Primary cluster id when configuring Global replication",
          :type => 'string'

attribute "ndb/replication/replica-cluster-id",
          :description =>  "Replica cluster id when configuring Global replication",
          :type => 'string'

attribute "ndb/replication/replicate-ignore-tables",
          :description =>  "Tables to ignore on the MySQL replica at Global replication",
          :type => 'string'

attribute "ndb/replication/role",
          :description =>  "In case of replication indicate if this cluster will be the primary or replica. Default: primary",
          :type => 'string'

attribute "ndb/replication/user",
          :description =>  "Replication user. Default: repl_user",
          :type => 'string'

attribute "ndb/replication/password",
          :description =>  "Password of the user doing the replication",
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

attribute "ndb/user_id",
          :description => "ndb user id. Default: 1519",
          :type => 'string'

attribute "ndb/group",
          :description => "Group that runs ndb database",
          :type => 'string'

attribute "ndb/group_id",
          :description => "ndb group id. Default: 1514",
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

attribute "ndb/restore/tarball",
          :description => "Location of RonDB backup tarball. The extracted directory is used by restore_backup.sh script. See comment in the script for the directory structure. Default: """,
          :type => 'string'

attribute "ndb/restore/backup_id",
          :description => "RonDB native RonDB backup ID to restore. It is used by restore_backup.sh script. Default: """,
          :type => 'string'

attribute "ndb/restore/exclude_databases_meta",
          :description => "Databases to exclude from restore-meta operation",
          :type => 'string'

attribute "ndb/restore/exclude_databases_data",
          :description => "Databases to exclude from restore-data operation",
          :type => 'string'

attribute "ndb/ndbd_backup_retention",
          :description => "How many n*24 hours are the backup files in NDB Data Nodes going to stay until they are removed",
          :type => 'string'

attribute "ndb/diskdata_dir",
          :description => "Directory on the NDBD machines where the on-disk columns will be stored. This should be a NVMe disk for best performance.",
          :type => 'string'

attribute "ndb/data_volume/root_dir",
          :description => "Root RonDB directory in data volume",
          :type => 'string'

attribute "ndb/data_volume/log_dir",
          :description => "RonDB log directory in data volume",
          :type => 'string'

attribute "ndb/data_volume/data_dir",
          :description => "FileSystemPath RonDB directory in data volume",
          :type => 'string'

attribute "ndb/data_volume/on_disk_columns",
          :description => "FileSystemPathDD RonDB directory in data volume",
          :type => 'string'

attribute "ndb/data_volume/mysql_server_dir",
          :description => "MySQL server directory in data volume",
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

attribute "mysql/no_fds",
          :description => "Max number of file descriptors allowed to MySQLd (Default: 10000)",
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

attribute "ndb/mgmd/port",
          :description => "Port used by Mgm servers in MySQL Cluster",
          :type => 'string'

attribute "ndb/mgmd/consul_tag",
          :description => "Consul tag associated to this mgmd service (Default: mgm)",
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

attribute "ndb/InitialLogFileGroup",
          :description => "Log files to create when performing an initial restart",
          :type => 'string'

attribute "ndb/InitialTablespace",
          :description => "Table space to create when performing an initial restart",
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

attribute "ndb/SpinMethod",
          :description => "SpinMethod",
          :type => 'string'

attribute "ndb/NumCPUs",
          :description => "If configuration type is set to auto controls how many CPUs will be available to ndbmtd. Default: -1 (use all CPUs)",
          :type => 'string'

attribute "ndb/TotalMemoryConfig",
          :description => "This configuration defines the amount of memory used by ndbmtd when AutomaticMemoryConfig is turned on. Minimum is 3G",
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

attribute "ndb/ndbd/port",
          :description =>  "Datanode port",
          :type => 'string'

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

attribute "ndb/mysqlx_port",
          :description => "Port on which the MySQL X plugin binds to",
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


# Rondb Rest API Server Configurations

attribute "ndb/rdrs/containerize",
          :description => "Run RDRS in a containerized environtment, such as docker. Default: true",
          :type => "string"

attribute "ndb/rdrs/container_image_url",
          :description => "RDRS image URL",
          :type => "string"

attribute "ndb/rdrs/version",
          :description => "RDRS API Version.",
          :type => "string"

attribute "ndb/rdrs/internal/buffer_size",
          :description => "Buffer size. This buffer is used to pass requests from go layer down to C++. The buffer has to be large enough to hold the request/response. Default: 327680",
          :type => "string"

attribute "ndb/rdrs/internal/pre_allocated_buffers",
          :description => "Number of preallocated buffers. Default: 1024",
          :type => "string"

attribute "ndb/rdrs/internal/go_max_procs",
          :description => "GOMAXPROCS. Default: -1",
          :type => "string"

attribute "ndb/rdrs/certificate_url",
          :description => "Optionally supply url to user issued certificate for REST/gRPC server, if not specified Hopsworks issued certificate will be used. Default: """,
          :type => "string"

attribute "ndb/rdrs/key_url",
          :description => "Optionally supply url to user issued key for REST/gRPC server, if not specified Hopsworks issued key will be used. Default: """,
          :type => "string"

attribute "ndb/rdrs/ca_url",
          :description => "Optionally supply url to CA certificate issued user certificate, if not specified Hopsworks (intermediate) CA bundle will be used. Default: """,
          :type => "string"

attribute "ndb/rdrs/rest/enable",
          :description => "Enable/Disable REST Interface. Default: true",
          :type => "string"

attribute "ndb/rdrs/rest/bind_ip",
          :description => "HTTP REST bind IP. Default: 0.0.0.0",
          :type => "string"

attribute "ndb/rdrs/rest/bind_port",
          :description => "HTTP REST bind port. Default: 4406",
          :type => "string"

attribute "ndb/rdrs/grpc/enable",
          :description => "Enable/Disable gRPC Interface. Default: true",
          :type => "string"

attribute "ndb/rdrs/grpc/bind_ip",
          :description => "gRPC bind IP. Default: 0.0.0.0",
          :type => "string"

attribute "ndb/rdrs/grpc/bind_port",
          :description => "gRPC bind port. Default: 5406",
          :type => "string"

attribute "ndb/rdrs/rondb/mgmds",
          :description => "RonDB management nodes connection information for data (Format: string IP:PORT)",
          :type => "string"

attribute "ndb/rdrs/rondb/connection_pool_size",
          :description => "Connection pool size. Default: 1",
          :type => "string"

attribute "ndb/rdrs/rondb/node_ids",
          :description => "This is the list of node ids to force the connections to be assigned to specific node ids.If this property is specified and connection pool size is not the default, the number of node ids must match the connection pool size",
          :type => "string"

attribute "ndb/rdrs/rondb/connection_retries",
          :description => "Connection retry attempts.",
          :type => "string"
	
attribute "ndb/rdrs/rondb/connection_retry_delay_in_sec",
          :description => "Delay in failed connection retry attempts",
          :type => "string"

attribute "ndb/rdrs/rondb/op_retry_on_transient_errors_count",
          :description => "Op retry on transient errors count",
          :type => "string"

attribute "ndb/rdrs/rondb/op_Retry_initial_delay_in_ms",
          :description => "Op retry initial delay in ms",
          :type => "string"

attribute "ndb/rdrs/rondb/op_retry_jitter_in_ms",
          :description => "Op retry jitter in ms",
          :type => "string"

attribute "ndb/rdrs/rondbmetadatacluster/mgmds",
          :description => "RonDB management nodes connection information for Hopsworks metadata (Format: string IP:PORT)",
          :type => "string"

attribute "ndb/rdrs/rondbmetadatacluster/connection_pool_size",
          :description => "Connection pool size. Default: 1",
          :type => "string"

attribute "ndb/rdrs/rondbmetadatacluster/node_ids",
          :description => "This is the list of node ids to force the connections to be assigned to specific node ids.If this property is specified and connection pool size is not the default, the number of node ids must match the connection pool size",
          :type => "string"

attribute "ndb/rdrs/rondbmetadatacluster/connection_retries",
          :description => "Connection retry attempts.",
          :type => "string"
	
attribute "ndb/rdrs/rondbmetadatacluster/connection_retry_delay_in_sec",
          :description => "Delay in failed connection retry attempts",
          :type => "string"

attribute "ndb/rdrs/rondbmetadatacluster/op_retry_on_transient_errors_count",
          :description => "Op retry on transient errors count",
          :type => "string"

attribute "ndb/rdrs/rondbmetadatacluster/op_Retry_initial_delay_in_ms",
          :description => "Op retry initial delay in ms",
          :type => "string"

attribute "ndb/rdrs/rondbmetadatacluster/op_retry_jitter_in_ms",
          :description => "Op retry jitter in ms",
          :type => "string"

attribute "ndb/rdrs/security/enable_tls",
          :description => "Enable TLS",
          :type => "string"

attribute "ndb/rdrs/security/require_and_verify_client_cert",
           :description => "Require and verify client certificate. Default: false",
          :type => "string"

attribute "ndb/rdrs/security/use_hopsworks_api_keys",
          :description => "Use hopsworks based API keys fro authentication and authorization. Default: false",
          :type => "string"

attribute "ndb/rdrs/security/cache_refresh_interval_ms",
          :description => "Hopsworks cache refresh interval ms",
          :type => "string"

attribute "ndb/rdrs/security/cache_unused_entries_eviction_ms",
          :description => "Hopsworks cache unused entries eviction ms",
          :type => "string"

attribute "ndb/rdrs/security/cache_refresh_interval_jitter_ms",
          :description => "Hopsworks cache refresh interval jitter ms",
          :type => "string"

attribute "ndb/rdrs/log/level",
          :description => "Log level. Default: info",
          :type => "string"

attribute "ndb/rdrs/log/file_path",
          :description => "Log file path.",
          :type => "string"

attribute "ndb/rdrs/log/max_size_mb",
          :description => "Log file max size. Default: 100 MB.",
          :type => "string"

attribute "ndb/rdrs/log/max_backups",
          :description => "Log max backup files. Default: 10",
          :type => "string"

attribute "ndb/rdrs/log/log_max_age",
          :description => "Log files max age. Default: 30",
          :type => "string"

attribute "featurestore/user",
          :description => "User for the JDBC Connection to the the Online FeatureStore",
          :type => 'string'

attribute "featurestore/password",
          :description => "Password for the JDBC Connection to the the Online FeatureStore",
          :type => 'string'