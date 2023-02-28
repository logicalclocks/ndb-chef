my_node_id = find_service_id("ndbd", 1)

# Don't ask
ndb_connectstring()
mgm_connection = node['ndb']['connectstring']
backup_directory = "#{node['ndb']['local_backup_dir']}/#{File.basename(node['ndb']['restore']['tarball'], ".tar.gz")}"
exclude_databases="glassfish_timers.EJB__TIMER__TBL"
private_ip=my_private_ip()
should_run = private_ip.eql?(node['ndb']['ndbd']['private_ips'].sort[0])

bash 'ndb_restore metadata' do
    user 'root'
    group 'root'
    timeout 18000
    code <<-EOH
        #{node['ndb']['scripts_dir']}/restore_backup.sh ndb-restore -p #{backup_directory} -n #{my_node_id} -b #{node['ndb']['restore']['backup_id']} -c #{mgm_connection} -s -e #{exclude_databases} -m META
    EOH
    only_if { should_run }
    only_if { rondb_restoring_backup() }
end