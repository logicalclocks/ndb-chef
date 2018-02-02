include_attribute "kagent"

version                                         ="7"
default['ndb']['majorVersion']                        ="5"
default['ndb']['minorVersion']                        ="6"

default['ndb']['version']                             = "#{version}.#{node['ndb']['majorVersion']}.#{node['ndb']['minorVersion']}"
default['ndb']['enabled']                             = "true"
default['ndb']['glib_version']                        = "2.5"

default['ndb']['url']                                 = node['download_url'] + "/mysql-cluster-gpl-#{node['ndb']['version']}-linux-glibc#{node['ndb']['glib_version']}-x86_64.tar.gz"
# checksum is not a security check - used to improve the speed of downloads by skipping if matched
# checksum calculated using: shasum -a 256 /var/www/hops/...tgz | cut -c-12
# checksum calculated using: sha256sum /var/www/hops/...tgz | cut -c-12
default['ndb']['checksum']                            = ""

default['ndb']['bind_cpus']                           = "false"

default['ndb']['mgmd']['port']                           = 1186
default['ndb']['ndbd']['port']                           = 10000
default['ndb']['ip']                                  = "10.0.2.15"

default['ndb']['loglevel']                            = "notice"
default['ndb']['user']                                = node['install']['user'].empty? ? "mysql" : node['install']['user']
default['ndb']['group']                               = node['install']['user'].empty? ? "mysql" : node['install']['user']
default['ndb']['connectstring']                       = ""

default['ndb']['DataMemory']                          = "50"
# Calculate IndexMemory size by default, can be overriden by user.
default['ndb']['IndexMemory']                         = ""
default['ndb']['NoOfReplicas']                        = "1"
default['ndb']['FragmentLogFileSize']                 = "64M"
default['ndb']['TcpBind_INADDR_ANY']                  = "FALSE"
default['ndb']['NoOfFragmentLogParts']                = "4"
default['ndb']['MaxNoOfTables']                       = "3036"
default['ndb']['MaxNoOfOrderedIndexes']               = "2048"
default['ndb']['MaxNoOfUniqueHashIndexes']            = "512"
default['ndb']['MaxDMLOperationsPerTransaction']      = "4297295"
default['ndb']['TransactionBufferMemory']             = "1M"
default['ndb']['MaxParallelScansPerFragment']         = "256"
default['ndb']['MaxDiskWriteSpeed']                   = "20M"
default['ndb']['MaxDiskWriteSpeedOtherNodeRestart']   = "50M"
default['ndb']['MaxDiskWriteSpeedOwnRestart']         = "200M"
default['ndb']['MinDiskWriteSpeed']                   = "5M"
default['ndb']['DiskSyncSize']                        = "4M"
default['ndb']['RedoBuffer']                          = "32M"
default['ndb']['LongMessageBuffer']                   = "64M"
default['ndb']['TransactionInactiveTimeout']          = "1500"
default['ndb']['TransactionDeadlockDetectionTimeout'] = "1500"
default['ndb']['LockPagesInMainMemory']               = "1"
default['ndb']['RealTimeScheduler']                   = "0"
default['ndb']['CompressedLCP']                       = "0"
default['ndb']['CompressedBackup']                    = "1"
default['ndb']['BackupMaxWriteSize']                  = "1M"
default['ndb']['BackupLogBufferSize']                 = "4M"
default['ndb']['BackupDataBufferSize']                = "16M"
default['ndb']['MaxAllocate']                         = "32M"
default['ndb']['DefaultHashMapSize']                  = "3840"
default['ndb']['ODirect']                             = "0"
default['ndb']['TotalSendBufferMemory']               = "4M"
# 0, in which case the effective overload limit is calculated as SendBufferMemory * 0.8 for a given connection.
default['ndb']['OverloadLimit']                       = "0"
# set to several MBs to protect the cluster against misbehaving API nodes that use excess send memory and thus cause failures in communications internally in the NDB kernel.
default['ndb']['MaxNoOfConcurrentScans']              = "500"
default['ndb']['MaxNoOfConcurrentIndexOperations']    = "30000"
default['ndb']['MaxNoOfConcurrentOperations']         = "200000"
default['ndb']['MaxNoOfFiredTriggers']                = "4000"
default['ndb']['MaxNoOfConcurrentTransactions']       = "16192"
default['ndb']['MaxNoOfAttributes']                   = "5000"

#Optimize for throughput: 0 (range 0..10)
default['ndb']['SchedulerResponsiveness']             = 0
default['ndb']['SchedulerSpinTimer']                  = 0
default['ndb']['SchedulerExecutionTimer']             = 75

default['ndb']['BuildIndexThreads']                   = 8
default['ndb']['TwoPassInitialNodeRestartCopy']       = "true"
default['ndb']['Numa']                                = 1


# Up to 8 execution threads supported
default['ndb']['MaxNoOfExecutionThreads']             = "2"
# Read up on this option first. Benefits from setting to "true" node['ndb']['interrupts_isolated_to_single_cpu']
default['ndb']['ThreadConfig']                        = ""


default['ndb']['interrupts_isolated_to_single_cpu']   = "false"

default['mgm']['scripts']            = %w{ backup-start.sh backup-restore.sh backup-remove.sh enter-singleuser-mode.sh mgm-client.sh mgm-server-start.sh mgm-server-stop.sh mgm-server-restart.sh cluster-shutdown.sh cluster-init.sh cluster-start-with-recovery.sh exit-singleuser-mode.sh }
default['ndb']['scripts']            = %w{ ndbd-start.sh ndbd-init.sh ndbd-stop.sh ndbd-restart.sh }
default['mysql']['scripts']          = %w{ get-mysql-socket.sh get-mysql-port.sh mysql-server-start.sh mysql-server-stop.sh mysql-server-restart.sh mysql-client.sh }
default['memcached']['scripts']      = %w{ memcached-start.sh memcached-stop.sh memcached-restart.sh }

default['ndb']['dir']                                 = node['install']['dir'].empty? ? "/var/lib" : node['install']['dir']
default['ndb']['root_dir']                            = "#{node['ndb']['dir']}/mysql-cluster"
default['ndb']['log_dir']                             = "#{node['ndb']['root_dir']}/log"
default['ndb']['data_dir']                            = "#{node['ndb']['root_dir']}/ndb_data"
default['ndb']['version_dir']                         = "#{node['ndb']['root_dir']}/ndb-#{node['ndb']['version']}"
default['ndb']['base_dir']                            = "#{node['ndb']['root_dir']}/ndb"

default['ndb']['BackupDataDir']                       = "#{node['ndb']['root_dir']}/ndb/backups"

default['ndb']['remote_backup_host']                  = ""
default['ndb']['remote_backup_user']                  = ""
default['ndb']['remote_backup_dir']                   = ""
default['ndb']['local_backup_dir']                    = ""
## How many n*24 hours are the backup files in NDB Data Nodes going to stay until they are removed
## NOTE: cron_backup attribute should be set to true
default['ndb']['ndbd_backup_retention']               = "5"

default['ndb']['scripts_dir']                         = "#{node['ndb']['root_dir']}/ndb/scripts"
default['ndb']['mgm_dir']                             = "#{node['ndb']['root_dir']}/mgmd"

# MySQL Server Parameters
default['ndb']['mysql_server_dir']                    = "#{node['ndb']['root_dir']}/ndb/mysql"
default['ndb']['num_ndb_slots_per_client']            = 1

# Max time that the mysqld and memcached will wait for the MySQL Cluster to be up and running.
# If the mysqld or memcached starts and the MySQL Cluster isn't running, it will not connect and will
# need to be restarted to connect to the cluster.
# Time in seconds
default['ndb']['wait_startup']                        = "10800"

# Base directory for MySQL binaries
default['mysql']['dir']                               = node['install']['dir'].empty? ? "/usr/local" : node['install']['dir']
# Symbolic link to the current versioned mysql directory
default['mysql']['base_dir']                          = "#{node['mysql']['dir']}/mysql"
# Concrete directory with mysql binaries for a specific mysql version
default['mysql']['version_dir']                       = "#{node['mysql']['base_dir']}-#{node['ndb']['version']}"

default['mysql']['jdbc_url']                          = ""

default['mysql']['localhost']                         = "false"

# MySQL Server Master-Slave replication binary log is enabled.
default['mysql']['replication_enabled']               = "false"

# This is the username/password for any mysql server (mysqld) started.
# It is required by mysql clients to use the mysql server.
default['mysql']['user']                              = "kthfs"
default['mysql']['password']                          = "kthfs"

# Limit the number of mgm_servers to the range 49..51
default['mgm']['id']                                  = 49
# All mysqlds, memcacheds, and ndbclients (clusterj) are in the range 52..255
default['mysql']['id']                                = 52
# up to 65 memcacheds
default['memcached']['id']                            = 125
# up to 65 NameNodes
default['nn']['id']                                   = 190

# The address of the mysqld that will be used by hop
default['ndb']['mysql_ip']                            = "10.0.2.15"

# Size in MB of memcached cache
default['memcached']['mem_size']                      = 64
# See examples here for configuration: http://dev.mysql.com/doc/ndbapi/en/ndbmemcache-configuration.html
# options examples: ";dev=role"   or ";dev=role;S:c4,g1,t1" or ";S:c0,g1,t1" ";role=db-only"
default['memcached']['options']                       = ";role=ndb-caching;usec_rtt=250;max_tps=100000;m=#{default['memcached']['mem_size']}"

#
# BitTorrent settings for copying NDB binaries
#
# default btsync ndb seeder_ip     = "default kagent dashboard_ip "
default['btsync']['ndb']['leechers']                     = ['10.0.2.15']

# IP addresses of the mgm-server, ndbds must be overridden by role/recipe caller.
default['ndb']['public_ips']                          = ['']
default['ndb']['private_ips']                         = ['']
default['ndb']['mgmd']['public_ips']                     = ['']
default['ndb']['mgmd']['private_ips']                    = ['']
default['ndb']['ndbd']['public_ips']                     = ['']
default['ndb']['ndbd']['private_ips']                    = ['']
default['ndb']['mysqld']['public_ips']                   = ['']
default['ndb']['mysqld']['private_ips']                  = ['']
default['ndb']['memcached']['public_ips']                = ['']
default['ndb']['memcached']['private_ips']               = ['']

default['ndb']['ndbapi']['addrs']                        = ['']

#default.ndb.dbt2_url                 = "http://downloads.mysql.com/source/dbt2-0.37.50.3.tar.gz"
#default.ndb.sysbench_url             = "http://downloads.mysql.com/source/sysbench-0.4.12.5.tar.gz"

default['ndb']['mgmd']['public_key']                     = ""
default['ndb']['aws_enhanced_networking']             = "false"

default['ndb']['cron_backup']                         = "false"
default['ndb']['backup_frequency']                    = "daily" # 'daily', 'weekly',
default['ndb']['backup_time']                         = "03:00"

default['ndb']['systemd']                             = node['systemd']

