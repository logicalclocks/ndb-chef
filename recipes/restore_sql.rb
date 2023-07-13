backup_directory = "#{node['ndb']['local_backup_dir']}/#{File.basename(node['ndb']['restore']['tarball'], ".tar.gz")}"
private_ip=my_private_ip()
should_run = private_ip.eql?(node['ndb']['mysqld']['private_ips'].sort[0])
mysql_cli = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

bash 'Restore SQL' do
    user 'root'
    group 'root'
    code <<-EOH
        set -e
        # Drop the procedures and view in case we retry
        #{mysql_cli} -e "DROP PROCEDURE IF EXISTS hops.simpleproc"
        #{mysql_cli} -e "DROP PROCEDURE IF EXISTS hops.flyway"
        #{mysql_cli} -e "DROP PROCEDURE IF EXISTS airflow.create_idx"
        #{mysql_cli} -e "DROP VIEW IF EXISTS hopsworks.users_groups"

        #{node['ndb']['scripts_dir']}/restore_backup.sh restore-schema -p #{backup_directory}
    EOH
    only_if { should_run }
    only_if { rondb_restoring_backup() }
end

hopsworks_consul = consul_helper.get_service_fqdn("hopsworks.glassfish")
bash 'Remove host certificates' do
    user 'root'
    group 'root'
    code <<-EOH
        set -e
        #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP '^C=.+ST=Sweden.+CN.+' AND status=1"
        #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^C=.+ST=Sweden.+CN.+'"

        # Two following queries revoke Glassfish'es internal certificate. First 2 are for before Hopsworks HA
        # and last two are after Hopsworks HA where we changed the Subject of the certificate
        #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP '^CN=#{hopsworks_consul}.+' AND status=1"
        #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^CN=#{hopsworks_consul}.+'"
        #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP 'L=glassfishinternal.+' AND status=1"
        #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP 'L=glassfishinternal.+'"
    EOH
    only_if { should_run }
    only_if { rondb_restoring_backup() }
end