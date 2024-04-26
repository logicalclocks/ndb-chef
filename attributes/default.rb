include_attribute "kagent"

default['ndb']['majorVersion']                        = "22"
default['ndb']['minorVersion']                        = "10"
default['ndb']['patchVersion']                        = "2"

default['ndb']['version']                             = "#{node['ndb']['majorVersion']}.#{node['ndb']['minorVersion']}.#{node['ndb']['patchVersion']}"
default['ndb']['enabled']                             = "true"
default['ndb']['glib_version']                        = "2.28"

default['ndb']['url']                                 = node['download_url'] + "/rondb-#{node['ndb']['version']}-linux-glibc#{node['ndb']['glib_version']}-x86_64.tar.gz"
# checksum is not a security check - used to improve the speed of downloads by skipping if matched
# checksum calculated using: shasum -a 256 /var/www/hops/...tgz | cut -c-12
# checksum calculated using: sha256sum /var/www/hops/...tgz | cut -c-12
default['ndb']['checksum']                            = ""
default['ndb']['configuration']['type']               = "auto"
default['ndb']['configuration']['profile']            = "unlimited"
default['ndb']['replication']['enabled']              = "false"
## TODO maybe I can remove cluster-id and role and keep only primary-cluster-id and replica-cluster-id
default['ndb']['replication']['cluster-id']           = "100"
default['ndb']['replication']['role']                 = "primary"
default['ndb']['replication']['primary-cluster-id']   = ""
default['ndb']['replication']['replica-cluster-id']   = ""
default['ndb']['replication']['replicate-ignore-tables'] = "glassfish_timers.EJB__TIMER__TBL"
default['ndb']['replication']['purge-binlog-interval-secs'] = "10"

default['ndb']['replication']['user']                 = "repl_user"
default['ndb']['replication']['password']             = "repl_password"

default['ndb']['bind_cpus']                           = "false"

default['ndb']['mgmd']['port']                        = 1186
default['ndb']['ndbd']['port']                        = 10000
default['ndb']['ndbd']['systemctl_timeout_sec']       = 3600
default['ndb']['ip']                                  = "10.0.2.15"

default['ndb']['loglevel']                            = "notice"
default['ndb']['user']                                = node['install']['user'].empty? ? "mysql" : node['install']['user']
default['ndb']['user_id']                             = '1519'
default['ndb']['user-home']                           = "/home/#{node['ndb']['user']}"
default['ndb']['group']                               = node['install']['user'].empty? ? "mysql" : node['install']['user']
default['ndb']['group_id']                            = '1514'
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
default['ndb']['MaxDMLOperationsPerTransaction']      = "32K"
default['ndb']['TransactionBufferMemory']             = "1M"
default['ndb']['MaxParallelScansPerFragment']         = "256"
default['ndb']['MaxDiskWriteSpeed']                   = "20M"
default['ndb']['MaxDiskWriteSpeedOtherNodeRestart']   = "50M"
default['ndb']['MaxDiskWriteSpeedOwnRestart']         = "200M"
default['ndb']['MinDiskWriteSpeed']                   = "10M"
default['ndb']['RedoBuffer']                          = "32M"
default['ndb']['LongMessageBuffer']                   = "64M"
default['ndb']['MaxFKBuildBatchSize']                 = "64"
default['ndb']['TransactionInactiveTimeout']          = "30000"
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
default['ndb']['TotalMemoryConfig']                   = "-1"
default['ndb']['ExtraSendBufferMemory']               = "0"
default['ndb']['TotalSendBufferMemory']               = "16M"
default['ndb']['DiskPageBufferEntries']               = "10"
default['ndb']['DiskPageBufferMemory']                = "512M"
default['ndb']['SharedGlobalMemory']                  = "512M"
default['ndb']['DiskIOThreadPool']                    = "8"
default['ndb']['DiskSyncSize']                        = "4M"
# Consult NDB documentation for the format
# https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-ndbd-definition.html#ndbparam-ndbd-initiallogfilegroup
default['ndb']['InitialLogFileGroup']                 = ""
default['ndb']['InitialTablespace']                   = ""

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
default['ndb']['SpinMethod']                          = "LatencyOptimisedSpinning"
default['ndb']['default']['NumCPUs']                  = "-1"
default['ndb']['NumCPUs']                             = "#{node['ndb']['default']['NumCPUs']}"


default['ndb']['interrupts_isolated_to_single_cpu']   = "false"

default['mgm']['scripts']            = %w{ enter-singleuser-mode.sh mgm-client.sh mgm-server-start.sh mgm-server-stop.sh mgm-server-restart.sh cluster-shutdown.sh cluster-init.sh cluster-start-with-recovery.sh exit-singleuser-mode.sh }
default['ndb']['scripts']            = %w{ ndbd-start.sh ndbd-init.sh ndbd-stop.sh ndbd-restart.sh }
default['mysql']['scripts']          = %w{ get-mysql-socket.sh get-mysql-port.sh mysql-server-start.sh mysql-server-stop.sh mysql-server-restart.sh mysql-client.sh }

default['ndb']['dir']                                 = node['install']['dir'].empty? ? "/var/lib" : node['install']['dir']

default['ndb']['root_dir']                            = "#{node['ndb']['dir']}/mysql-cluster"
default['ndb']['log_dir']                             = "#{node['ndb']['root_dir']}/log"
default['ndb']['data_dir']                            = "#{node['ndb']['root_dir']}/ndb_data"
default['ndb']['version_dir']                         = "#{node['ndb']['root_dir']}/ndb-#{node['ndb']['version']}"
default['ndb']['base_dir']                            = "#{node['ndb']['root_dir']}/ndb"

# Data volume directories
default['ndb']['data_volume']['root_dir']             = "#{node['data']['dir']}/rondb"
default['ndb']['data_volume']['log_dir']              = "#{node['ndb']['data_volume']['root_dir']}/log"
default['ndb']['data_volume']['data_dir']             = "#{node['ndb']['data_volume']['root_dir']}/ndb_data"
default['ndb']['data_volume']['on_disk_columns']      = "#{node['ndb']['data_volume']['root_dir']}/#{node['ndb']['ndb_disk_columns_dir_name']}"
default['ndb']['data_volume']['mysql_server_dir']     = "#{node['ndb']['data_volume']['root_dir']}/mysql"

# Small file storage parameters

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
default['ndb']['local_backup_dir']                    = "#{node['ndb']['root_dir']}/ndb/backups"
default['ndb']['restore']['tarball']                  = ""
default['ndb']['restore']['backup_id']                = ""
default['ndb']['restore']['exclude_databases_meta']   = "mysql.ndb_apply_status,glassfish_timers.EJB__TIMER__TBL"
default['ndb']['restore']['exclude_databases_data']   = "mysql.ndb_apply_status,glassfish_timers.EJB__TIMER__TBL,hopsworks.hosts,hopsworks.host_services"
default['ndb']['restore']['revoke_host_certificates'] = "false"
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
default['mysql']['bin_dir']                           = "#{node['mysql']['base_dir']}/bin"
# Concrete directory with mysql binaries for a specific mysql version
default['mysql']['version_dir']                       = "#{node['mysql']['base_dir']}-#{node['ndb']['version']}"

# Location for the MySQL socket - needs to be in a directory which is accessible only to the mysql user
default['ndb']['mysql_socket']                        = "#{node['ndb']['root_dir']}/mysql.sock"
default['ndb']['mysqlx_socket']                       = "#{node['ndb']['root_dir']}/mysqlx.sock"
default['ndb']['mysql_port']                          = "3306"
default['ndb']['mysqlx_port']                         = "33060"

default['mysql']['localhost']                         = "false"

# MySQL Server TLS/SSL enabled
default['mysql']['tls']                               = "false"

# This is the username/password for any mysql server (mysqld) started.
# It is required by mysql clients to use the mysql server.
default['mysql']['user']                              = "kthfs"
default['mysql']['password']                          = "kthfs"

default['mysql']['initialize']                        = "true"

# When this attribute is enabled incompatible changes in mysql.ndb_schema
# will NOT be made
#
#
# NOTE: You need to run recipe ndb::commit_upgrade on all MySQL servers MANUALLY post upgrade
#
#
default['mysql']['safe-upgrade']                      = "false"

# Number of file descriptor allocated to MySQLd server
default['mysql']['no_fds']                            = 10000

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
default['ndb']['mysqld_exporter']['version']                = "0.11.2"
default['ndb']['mysqld_exporter']['url']                    = "#{node['download_url']}/prometheus/mysqld_exporter-#{node['ndb']['mysqld_exporter']['version']}.linux-amd64.tar.gz"
default['ndb']['mysqld_exporter']['home']                   = "#{node['ndb']['dir']}/mysqld_exporter-#{node['ndb']['mysqld_exporter']['version']}.linux-amd64"
default['ndb']['mysqld_exporter']['base_dir']               = "#{node['ndb']['dir']}/mysqld_exporter"
default['ndb']['mysqld']['metrics_port']                    = "9104"


# Rondb Rest API Server Configurations
default['ndb']['rdrs']['version']                                                    = "0.1.0"
default['ndb']['rdrs']['containerize']                                               = "true"
default['ndb']['rdrs']['container_image_url']                                        = node['download_url'] + "/docker-image-rdrs-#{node['ndb']['version']}.tar.gz"
default['ndb']['rdrs']['internal']['buffer_size']                                    = "5242880"
default['ndb']['rdrs']['internal']['pre_allocated_buffers']                          = "32"
default['ndb']['rdrs']['internal']['go_max_procs']                                   = "-1"
#if go_max_procs is -1 then number of threads
#used by go runtime is same as no of CPU cores
default['ndb']['rdrs']['certificate_url']                                            = ""
default['ndb']['rdrs']['key_url']                                                    = ""
default['ndb']['rdrs']['ca_url']                                                     = ""

default['ndb']['rdrs']['rest']['enable']                                             = "true"
default['ndb']['rdrs']['rest']['bind_ip']                                            = "0.0.0.0"
default['ndb']['rdrs']['rest']['bind_port']                                          = "4406"

default['ndb']['rdrs']['grpc']['enable']                                             = "true"
default['ndb']['rdrs']['grpc']['bind_ip']                                            = "0.0.0.0"
default['ndb']['rdrs']['grpc']['bind_port']                                          = "5406"

default['ndb']['rdrs']['rondb']['mgmds']                                             = ""
default['ndb']['rdrs']['rondb']['connection_pool_size']                              = "1"
default['ndb']['rdrs']['rondb']['node_ids']                                          = "[0]"
default['ndb']['rdrs']['rondb']['connection_retries']                                = "1"
default['ndb']['rdrs']['rondb']['connection_retry_delay_in_sec']                     = "1"
default['ndb']['rdrs']['rondb']['op_retry_on_transient_errors_count']                = "3"
default['ndb']['rdrs']['rondb']['op_retry_initial_delay_in_ms']                      = "500"
default['ndb']['rdrs']['rondb']['op_retry_jitter_in_ms']                             = "100"

default['ndb']['rdrs']['rondbmetadatacluster']['mgmds']                              = ""
default['ndb']['rdrs']['rondbmetadatacluster']['connection_pool_size']               = "1"
default['ndb']['rdrs']['rondbmetadatacluster']['node_ids']                           = "[0]"
default['ndb']['rdrs']['rondbmetadatacluster']['connection_retries']                 = "1"
default['ndb']['rdrs']['rondbmetadatacluster']['connection_retry_delay_in_sec']      = "1"
default['ndb']['rdrs']['rondbmetadatacluster']['op_retry_on_transient_errors_count'] = "3"
default['ndb']['rdrs']['rondbmetadatacluster']['op_retry_initial_delay_in_ms']       = "500"
default['ndb']['rdrs']['rondbmetadatacluster']['op_retry_jitter_in_ms']              = "100"

default['ndb']['rdrs']['security']['enable_tls']                                     = "true"
default['ndb']['rdrs']['security']['require_and_verify_client_cert']                 = "false"
default['ndb']['rdrs']['security']['use_hopsworks_api_keys']                         = "true"
default['ndb']['rdrs']['security']['cache_refresh_interval_ms']                      = "10000"
default['ndb']['rdrs']['security']['cache_unused_entries_eviction_ms']               = "60000"
default['ndb']['rdrs']['security']['cache_refresh_interval_jitter_ms']               = "1000"

default['ndb']['rdrs']['log']['level']                                               = "info"
default['ndb']['rdrs']['log']['file_path']                                           = ""
default['ndb']['rdrs']['log']['max_size_mb']                                         = "100"
default['ndb']['rdrs']['log']['max_backups']                                         = "10"
default['ndb']['rdrs']['log']['log_max_age']                                         = "30"

default['ndb']['rdrs']['scripts']                                                    = %w{ rdrs-start.sh rdrs-stop.sh rdrs-restart.sh }

default['ndb']['ulimit_file']                                          = "/etc/security/limits.d/#{node['ndb']['user']}.conf"

## Consul
default['ndb']['mgmd']['consul_tag']                                   = "mgm"

# Featurestore MySQL Configuration
default['featurestore']['user']                       = "featurestore_admin_user"
default['featurestore']['password']                   = "featurestore_admin_pwd"

# Use this MySQL server as Online FS
default['mysql']['onlinefs']                          = "true"
