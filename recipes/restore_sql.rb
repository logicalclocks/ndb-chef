backup_directory = node['ndb']['local_backup_dir']
private_ip=my_private_ip()
should_run = private_ip.eql?(node['ndb']['mysqld']['private_ips'].sort[0])

bash 'Restore SQL' do
    user 'root'
    group 'root'
    code <<-EOH
        #{node['ndb']['scripts_dir']}/restore_backup.sh restore-schema -p #{backup_directory}
    EOH
    only_if { should_run }
    not_if { backup_directory.empty? }
end

mysql_cli = "#{node['ndb']['scripts_dir']}/mysql-client.sh"
hopsworks_consul = consul_helper.get_service_fqdn("hopsworks.glassfish")
bash 'Remove host certificates' do
    user 'root'
    group 'root'
    code <<-EOH
        #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^C.+ST=Sweden.+CN.+'"
        #{mysql_cli} -e "UPDATE hopsworks.pki_certificate SET status=1 WHERE subject REGEXP '^CN=#{hopsworks_consul}.+';"
    EOH
    only_if { should_run }
    not_if { backup_directory.empty? }
end