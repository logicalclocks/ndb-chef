backup_directory = node['ndb']['restore']['directory']
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
    not_if { backup_directory.empty? }
end

hopsworks_consul = consul_helper.get_service_fqdn("hopsworks.glassfish")
bash 'Remove host certificates' do
    user 'root'
    group 'root'
    code <<-EOH
        set -e
        #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP '^C=.+ST=Sweden.+CN.+' AND status=1"
        #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^C=.+ST=Sweden.+CN.+'"

        #{mysql_cli} -e "DELETE FROM hopsworks.pki_certificate WHERE subject REGEXP '^CN=#{hopsworks_consul}.+' AND status=1"
        #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^CN=#{hopsworks_consul}.+'"
    EOH
    only_if { should_run }
    not_if { backup_directory.empty? }
end