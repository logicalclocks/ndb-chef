include_attribute "kagent"

version                                               ="8"
default['ndb']['majorVersion']                        ="0"
default['ndb']['minorVersion']                        ="21"

default['ndb']['version']                             = "#{version}.#{node['ndb']['majorVersion']}.#{node['ndb']['minorVersion']}"
default['ndb']['enabled']                             = "true"
default['ndb']['glib_version']                        = "2.12"

default['ndb']['url']                                 = node['download_url'] + "/mysql-cluster-#{node['ndb']['version']}-linux-glibc#{node['ndb']['glib_version']}-x86_64.tar.gz"
# checksum is not a security check - used to improve the speed of downloads by skipping if matched
# checksum calculated using: shasum -a 256 /var/www/hops/...tgz | cut -c-12
# checksum calculated using: sha256sum /var/www/hops/...tgz | cut -c-12
default['ndb']['checksum']                            = ""

default['ndb']['bind_cpus']                           = "false"

default['ndb']['mgmd']['port']                        = 1186
default['ndb']['ndbd']['port']                        = 10000
default['ndb']['ndbd']['systemctl_timeout_sec']       = 3600
default['ndb']['ip']                                  = "10.0.2.15"

default['ndb']['loglevel']                            = "notice"
default['ndb']['user']                                = node['install']['user'].empty? ? "mysql" : node['install']['user']
default['ndb']['user-home']                           = "/home/#{node['ndb']['user']}"
default['ndb']['group']                               = node['install']['user'].empty? ? "mysql" : node['install']['user']
default['ndb']['connectstring']                       = ""

default['ndb']['DataMemory']                          = "512"
default['ndb']['NoOfReplicas']                        = "1"
default['ndb']['TcpBind_INADDR_ANY']                  = "FALSE"
default['ndb']['NoOfFragmentLogParts']                = "4"
default['ndb']['NoOfFragmentLogFiles']                = "16"
default['ndb']['FragmentLogFileSize']                 = "16M"
default['ndb']['MaxNoOfTables']                       = "4096"
default['ndb']['MaxNoOfOrderedIndexes']               = "2048"
default['ndb']['MaxNoOfUniqueHashIndexes']            = "512"
default['ndb']['MaxNoOfTriggers']                     = "2048"
default['ndb']['MaxDMLOperationsPerTransaction']      = "4294967295"
default['ndb']['TransactionBufferMemory']             = "1M"
default['ndb']['MaxParallelScansPerFragment']         = "256"
default['ndb']['MaxDiskWriteSpeed']                   = "20M"
default['ndb']['MaxDiskWriteSpeedOtherNodeRestart']   = "50M"
default['ndb']['MaxDiskWriteSpeedOwnRestart']         = "200M"
default['ndb']['MinDiskWriteSpeed']                   = "10M"
default['ndb']['RedoBuffer']                          = "32M"
default['ndb']['LongMessageBuffer']                   = "64M"
default['ndb']['MaxFKBuildBatchSize']                 = "64"
default['ndb']['TransactionInactiveTimeout']          = "1500"
default['ndb']['TransactionDeadlockDetectionTimeout'] = "1500"
default['ndb']['LockPagesInMainMemory']               = "1"
default['ndb']['RealTimeScheduler']                   = "0"
default['ndb']['CompressedLCP']                       = "0"
default['ndb']['CompressedBackup']                    = "1"
default['ndb']['BackupMaxWriteSize']                  = "1M"
default['ndb']['BackupLogBufferSize']                 = "16M"
default['ndb']['BackupDataBufferSize']                = "16M"
default['ndb']['MaxAllocate']                         = "32M"
default['ndb']['DefaultHashMapSize']                  = "3840"
default['ndb']['ODirect']                             = "0"
default['ndb']['ExtraSendBufferMemory']               = "0"
default['ndb']['TotalSendBufferMemory']               = "16M"
default['ndb']['DiskPageBufferEntries']               = "10"
default['ndb']['DiskPageBufferMemory']                = "512M"
default['ndb']['SharedGlobalMemory']                  = "512M"
default['ndb']['DiskIOThreadPool']                    = "8"
default['ndb']['InitialLogFileGroup=name']            = "LG1; undo_buffer_size=40M; undo1.log:80M;"
default['ndb']['DiskSyncSize']                        = "4M"
# Move this to another drive to store small files in HopsFS
default['ndb']['InitialTablespacename']               = "TS1; extent_size=8M; data1.dat:240M;"

# From 7.6.7 - no configuration needed for disk write speeds
# https://mikaelronstrom.blogspot.com/2018/08/more-automated-control-in-mysql-cluster.html
default['ndb']['EnableRedoControl']                   = "1"


# 0, in which case the effective overload limit is calculated as SendBufferMemory * 0.8 for a given connection.
default['ndb']['OverloadLimit']                       = "0"
# set to several MBs to protect the cluster against misbehaving API nodes that use excess send memory and thus cause failures in communications internally in the NDB kernel.
default['ndb']['MaxNoOfConcurrentScans']              = "500"
default['ndb']['MaxNoOfConcurrentIndexOperations']    = "32000"
default['ndb']['MaxNoOfConcurrentOperations']         = "200000"
default['ndb']['MaxNoOfFiredTriggers']                = "10240"
default['ndb']['MaxNoOfConcurrentTransactions']       = "16192"
default['ndb']['MaxNoOfAttributes']                   = "5000"

default['ndb']['MaxReorgBuildBatchSize']              = "64" 
default['ndb']['EnablePartialLcp']                    = "1"
default['ndb']['RecoveryWork']                        = "60"
default['ndb']['InsertRecoveryWork']                  = "40"


#Optimize for throughput: 0 (range 0..10)
default['ndb']['SchedulerResponsiveness']             = 5
default['ndb']['SchedulerSpinTimer']                  = 0
default['ndb']['SchedulerExecutionTimer']             = 50 

default['ndb']['BuildIndexThreads']                   = "128"
default['ndb']['TwoPassInitialNodeRestartCopy']       = "true"
default['ndb']['Numa']                                = 1


# Up to 8 execution threads supported
default['ndb']['MaxNoOfExecutionThreads']             = "8"
# Read up on this option first. Benefits from setting to "true" node['ndb']['interrupts_isolated_to_single_cpu']
default['ndb']['ThreadConfig']                        = ""


default['ndb']['interrupts_isolated_to_single_cpu']   = "false"

default['mgm']['scripts']            = %w{ backup-start.sh backup-restore.sh backup-remove.sh enter-singleuser-mode.sh mgm-client.sh mgm-server-start.sh mgm-server-stop.sh mgm-server-restart.sh cluster-shutdown.sh cluster-init.sh cluster-start-with-recovery.sh exit-singleuser-mode.sh }
default['ndb']['scripts']            = %w{ ndbd-start.sh ndbd-init.sh ndbd-stop.sh ndbd-restart.sh }
default['mysql']['scripts']          = %w{ get-mysql-socket.sh get-mysql-port.sh mysql-server-start.sh mysql-server-stop.sh mysql-server-restart.sh mysql-client.sh }

default['ndb']['dir']                                 = node['install']['dir'].empty? ? "/var/lib" : node['install']['dir']
default['ndb']['root_dir']                            = "#{node['ndb']['dir']}/mysql-cluster"
default['ndb']['log_dir']                             = "#{node['ndb']['root_dir']}/log"
default['ndb']['data_dir']                            = "#{node['ndb']['root_dir']}/ndb_data"
default['ndb']['version_dir']                         = "#{node['ndb']['root_dir']}/ndb-#{node['ndb']['version']}"
default['ndb']['base_dir']                            = "#{node['ndb']['root_dir']}/ndb"

# Small file storage parameters

default['ndb']['InitialLogFileGroup']                 = "undo_buffer_size=128M; "
# NDB Cluster Disk Data data files and undo log files are placed in the diskdata_dir directory
default['ndb']['ndb_disk_columns_dir_name']           = "ndb_disk_columns"
default['ndb']['diskdata_dir']                        = "#{node['ndb']['root_dir']}/#{node['ndb']['ndb_disk_columns_dir_name']}"
default['ndb']['nvme']['small_file']                  = "2000"
default['ndb']['nvme']['med_file']                    = "4000"
default['ndb']['nvme']['large_file']                  = "8000"
# size in MBs of the logfile
default['ndb']['nvme']['logfile_size']                = ""
default['ndb']['nvme']['undofile_size']               = "3000M"
default['ndb']['nvme']['mount_base_dir']              = "/mnt/nvmeDisks"
default['ndb']['nvme']['mount_disk_prefix']           = "nvme"
default['ndb']['nvme']['devices']                     = []
default['ndb']['nvme']['format']                      = "false"

default['ndb']['BackupDataDir']                       = "#{node['ndb']['root_dir']}/ndb/backups"

default['ndb']['remote_backup_host']                  = ""
default['ndb']['remote_backup_user']                  = ""
default['ndb']['remote_backup_dir']                   = ""
default['ndb']['local_backup_dir']                    = ""
## How many n*24 hours are the backup files in NDB Data Ndes going to stay until they are removed
## NOTE: cron_backup attribute should be set to true
default['ndb']['ndbd_backup_retention']               = "5"

default['ndb']['scripts_dir']                         = "#{node['ndb']['root_dir']}/ndb/scripts"
default['ndb']['mgm_dir']                             = "#{node['ndb']['root_dir']}/mgmd"
# MySQL Server Parameters
default['ndb']['mysql_server_dir']                    = "#{node['ndb']['root_dir']}/mysql"
default['ndb']['num_ndb_slots_per_client']            = 1
default['ndb']['num_ndb_slots_per_mysqld']            = 1
default['ndb']['num_ndb_open_slots']                  = 10

# Max time that the mysqld will wait for the MySQL Cluster to be up and running.
# If the mysqld starts and the MySQL Cluster isn't running, it will not connect and will
# need to be restarted to connect to the cluster.
# Time in seconds
default['ndb']['wait_startup']                        = "10800"


# Base directory for MySQL binaries
default['mysql']['dir']                               = node['install']['dir'].empty? ? "/usr/local" : node['install']['dir']
# Symbolic link to the current versioned mysql directory
default['mysql']['base_dir']                          = "#{node['mysql']['dir']}/mysql"
# Concrete directory with mysql binaries for a specific mysql version
default['mysql']['version_dir']                       = "#{node['mysql']['base_dir']}-#{node['ndb']['version']}"

# Location for the MySQL socket - needs to be in a directory which is accessible only to the mysql user
default['ndb']['mysql_socket']                        = "#{node['ndb']['root_dir']}/mysql.sock"
default['ndb']['mysql_port']                          = "3306"

default['mysql']['localhost']                         = "false"
default['mysql']['jdbc_url']                          = ""


# MySQL Server Master-Slave replication binary log is enabled.
default['mysql']['replication_enabled']               = "false"

# MySQL Server TLS/SSL enabled
default['mysql']['tls']                               = "false"

# This is the username/password for any mysql server (mysqld) started.
# It is required by mysql clients to use the mysql server.
default['mysql']['user']                              = "kthfs"
default['mysql']['password']                          = "kthfs"

default['mysql']['initialize']                        = "true"

# Limit the number of mgm_servers to the range 49..51
default['mgm']['id']                                  = 49
# All mysqlds, and ndbclients (clusterj) are in the range 52..255
default['mysql']['id']                                = 52
# up to 65 NameNodes
default['nn']['id']                                   = 190

# IP addresses of the mgm-server, ndbds must be overridden by role/recipe caller.
default['ndb']['public_ips']                             = ['']
default['ndb']['private_ips']                            = ['']
default['ndb']['mgmd']['public_ips']                     = ['']
default['ndb']['mgmd']['private_ips']                    = ['']
default['ndb']['ndbd']['public_ips']                     = ['']
default['ndb']['ndbd']['private_ips']                    = ['']
default['ndb']['mysqld']['public_ips']                   = ['']
default['ndb']['mysqld']['private_ips']                  = ['']

#
# ndbd entries in the config.ini file.
# The format should be ["ip1:id1", "ip2:id2", ...]
# If this attribute is not overriden, the ndbd instances will be ordered by
# ip_address, and the id '1' will be given to the first ndbd, '2' to the next ndbd, etc.
#
default['ndb']['ndbd']['ips_ids']                        = []
default['ndb']['mysqld']['ips_ids']                      = []

#default.ndb.dbt2_url                 = "http://downloads.mysql.com/source/dbt2-0.37.50.3.tar.gz"
#default.ndb.sysbench_url             = "http://downloads.mysql.com/source/sysbench-0.4.12.5.tar.gz"

default['ndb']['mgmd']['public_key']                     = ""
default['ndb']['aws_enhanced_networking']             = "false"

default['ndb']['cron_backup']                         = "false"
default['ndb']['backup_frequency']                    = "daily" # 'daily', 'weekly',
default['ndb']['backup_time']                         = "03:00"

#LocationDomainId
default['ndb']['mgmd']['private_ips_domainIds']          = {}
default['ndb']['ndbd']['private_ips_domainIds']          = {}
default['ndb']['mysqld']['private_ips_domainIds']        = {}

# Metrics  
default['ndb']['mysqld_exporter']['version']                = "0.11.0"
default['ndb']['mysqld_exporter']['url']                    = "#{node['download_url']}/prometheus/mysqld_exporter-#{node['ndb']['mysqld_exporter']['version']}.linux-amd64.tar.gz"
default['ndb']['mysqld_exporter']['home']                   = "#{node['ndb']['dir']}/mysqld_exporter-#{node['ndb']['mysqld_exporter']['version']}.linux-amd64"
default['ndb']['mysqld_exporter']['base_dir']               = "#{node['ndb']['dir']}/mysqld_exporter"
default['ndb']['mysqld']['metrics_port']                    = "9104"
