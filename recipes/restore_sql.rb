backup_directory = "#{node['ndb']['local_backup_dir']}/#{File.basename(node['ndb']['restore']['tarball'], ".tar.gz")}"
private_ip=my_private_ip()
ndb_connectstring()
mgm_connection = node['ndb']['connectstring']
should_run = private_ip.eql?(node['ndb']['restore_sql']['private_ips'].sort[0])
mysql_cli = "#{node['ndb']['scripts_dir']}/mysql-client.sh"
mysql_socket = node['ndb']['mysql_socket']
mysql_client = "#{node['mysql']['bin_dir']}/mysql"

exclude_databases_option = ""
exclude_tables_option = ""
exclude_disk_objects_option = ""
unless node['ndb']['restore']['exclude_tables_meta'].empty?
    exclude_tables_option = "-e #{node['ndb']['restore']['exclude_tables_meta']}"
end
unless node['ndb']['restore']['exclude_databases_meta'].empty?
    exclude_databases_option = "-x #{node['ndb']['restore']['exclude_databases_meta']}"
end
unless node['ndb']['restore']['exclude_disk_objects'].eql?("false")
    exclude_disk_objects_option = "-d"
end
rebuild_indexes_check = "#{Chef::Config['file_cache_path']}/rondb_rebuild_indexes_#{node['install']['version']}_#{node['ndb']['version']}"

bash 'Rebuild indexes' do
    user 'root'
    group 'root'
    live_stream true
    code <<-EOH
        set -e
        #{node['ndb']['scripts_dir']}/restore_backup.sh ndb-restore -p #{backup_directory} -n 1 -b #{node['ndb']['restore']['backup_id']} -c #{mgm_connection} #{exclude_tables_option} #{exclude_databases_option} #{exclude_disk_objects_option} -m REBUILD-INDEXES
        touch #{rebuild_indexes_check}
    EOH
    # Add this check to avoid re-running this block in case one of the following steps
    # fail and the recipe is retried
    not_if { ::File.exists?(rebuild_indexes_check) }
    only_if { should_run }
    only_if { rondb_restoring_backup() }
end

# Temporary fix for the GRANTS propagation issue
# https://hopsworks.atlassian.net/browse/RONDB-647
# restarting mysqld will syncronize the tables
systemd_unit "mysqld.service" do
    action [:restart]
end

bash 'Restore SQL' do
    user 'root'
    group 'root'
    live_stream true
    code <<-EOH
        set -e
        # Drop existing procedures as they will be restored from the backup
        stored_procs=$(#{mysql_client} -S #{mysql_socket} -Nse "SELECT routine_schema, routine_name FROM information_schema.routines WHERE routine_schema IN ('airflow', 'hopsworks', 'hops')" | awk '{c=$1"."$2; print c}')
        stored_procs=$(echo $stored_procs | sed 's/[[:space:]]/,/g')
        for p in ${stored_procs//,/ }
        do
            echo "Dropping stored procedure $p"
            #{mysql_cli} -e "DROP PROCEDURE IF EXISTS $p"
        done


        # Drop existing procedures as they will be restored from the backup
        views=$(#{mysql_client} -S #{mysql_socket} -Nse "SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.tables WHERE TABLE_TYPE = 'VIEW' and TABLE_SCHEMA IN ('airflow', 'hopsworks', 'hops')" | awk '{c=$1"."$2; print c}')
        views=$(echo $views | sed 's/[[:space:]]/,/g')
        for p in ${views//,/ }
        do
            echo "Dropping view $p"
            #{mysql_cli} -e "DROP VIEW IF EXISTS $p"
        done

        #{node['ndb']['scripts_dir']}/restore_backup.sh restore-schema -p #{backup_directory}
    EOH
    only_if { should_run }
    only_if { rondb_restoring_backup() }
end

# This step is needed to initialize some internal data structures in case of Global async
# replication (https://docs.rondb.com/rondb_restore/#restoring-metadata)
# We do it regardless the setup as it is harmless
bash 'Initialize MySQL binlog' do
    user 'root'
    group 'root'
    code <<-EOH
        set -e
        #{node['ndb']['scripts_dir']}/restore_backup.sh show-tables
    EOH
    only_if { rondb_restoring_backup() }
end

hopsworks_consul = consul_helper.get_service_fqdn("hopsworks.glassfish")
bash 'Remove host certificates' do
    user 'root'
    group 'root'
    code <<-EOH
        set +e
        #{mysql_cli} -e "use hopsworks" 1> /dev/null 2> /dev/null
        if [ "$?" -eq 0 ]; then
            set -e
            echo "Hopsworks database exists"
            #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP '^C=.+ST=Sweden.+CN.+' AND status=1"
            #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^C=.+ST=Sweden.+CN.+'"

            # Two following queries revoke Glassfish'es internal certificate. First 2 are for before Hopsworks HA
            # and last two are after Hopsworks HA where we changed the Subject of the certificate
            #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP '^CN=#{hopsworks_consul}.+' AND status=1"
            #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^CN=#{hopsworks_consul}.+'"
            #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP 'L=glassfishinternal.+' AND status=1"
            #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP 'L=glassfishinternal.+'"
        else
            echo "Hopsworks database DOES NOT exist"
        fi
    EOH
    only_if { node['ndb']['restore']['revoke_host_certificates'].casecmp?("true") }
    only_if { should_run }
    only_if { rondb_restoring_backup() }
end

##
## NOTE: This should always be the last step in this recipe
##
file rebuild_indexes_check do
    action :delete
end
