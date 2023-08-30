my_node_id = find_service_id('ndb_restore_data', 1)

# Don't ask
ndb_connectstring()
mgm_connection = node['ndb']['connectstring']
backup_directory = "#{node['ndb']['local_backup_dir']}/#{File.basename(node['ndb']['restore']['tarball'], ".tar.gz")}"
exclude_databases_option = ""
unless node['ndb']['restore']['exclude_databases_data'].empty?
    exclude_databases_option = "-e #{node['ndb']['restore']['exclude_databases_data']}"
end

bash 'ndb_restore data' do
    user 'root'
    group 'root'
    code <<-EOH
        #{node['ndb']['scripts_dir']}/restore_backup.sh ndb-restore -p #{backup_directory} -n #{my_node_id} -b #{node['ndb']['restore']['backup_id']} -c #{mgm_connection} #{exclude_databases_option} -m DATA
    EOH
    only_if { rondb_restoring_backup() }
end

bash 'ndb_restore epoch' do
    user 'root'
    group 'root'
    code <<-EOH
        #{node['ndb']['scripts_dir']}/restore_backup.sh ndb-restore -p #{backup_directory} -n #{my_node_id} -b #{node['ndb']['restore']['backup_id']} -c #{mgm_connection} -m RESTORE-EPOCH
    EOH
    only_if { rondb_restoring_backup() }
end