include_recipe "ndb::replication_configuration"

my_ip = my_private_ip()
replica_ips = node['ndb']['mysql_replica']['private_ips']
idx = replica_ips.sort().index(my_ip)

ips = node['ndb']['mysql_primary']['private_ips']
primary_mysql = ips.sort()[idx]

primary_server_id = mysql_server_id(primary_mysql, node['ndb']['replication']['primary-cluster-id'])

my_server_id = mysql_server_id(my_ip, node['ndb']['replication']['replica-cluster-id'])

configured_check_file = "#{node['ndb']['root_dir']}/ndb/replication_channel_configured"
if ::File.exists?(configured_check_file)
    raise "RonDB replication has already been configured! If you really want to proceed delete #{configured_check_file} and re-try with a different backup-id"
end

# make sure there is no entry in the heartbeat table where I am primary ie switching role
bash 'delete-primary-with-my-id' do
    user node['ndb']['user']
    group node['ndb']['group']
    code <<-EOF
        set -e
        #{node['mysql']['bin_dir']}/mysql -h #{primary_mysql} -u #{node['ndb']['replication']['user']} -p#{node['ndb']['replication']['password']} -Nse "DELETE FROM rondb_replication.heartbeat_tbl WHERE primary_id=#{my_server_id}"
    EOF
end

ids = []

for replica_ip in replica_ips do
    ids.push(mysql_server_id(replica_ip, node['ndb']['replication']['replica-cluster-id']))
end
replica_server_ids = ids.join(",")

Chef::Log.info "I am replica #{my_ip} and my primary will be #{primary_mysql}"

bash 'initial-replication-configuration' do
    user node['ndb']['user']
    code <<-EOF
    set -e
    #{node['ndb']['scripts_dir']}/mysql-client.sh -e "STOP REPLICA"
    #{node['ndb']['scripts_dir']}/mysql-client.sh -e "CHANGE REPLICATION SOURCE TO \
        SOURCE_HOST='#{primary_mysql}', \
        SOURCE_USER='#{node['ndb']['replication']['user']}', \
        SOURCE_PORT=#{node['ndb']['mysql_port']}, \
        SOURCE_PASSWORD='#{node['ndb']['replication']['password']}', \
        SOURCE_LOG_FILE='binlog.000001', \
        SOURCE_LOG_POS=4, \
        IGNORE_SERVER_IDS=(#{replica_server_ids});"
    EOF
end

active = idx == 0

bash 'change-heartbeat_tbl' do
    user node['ndb']['user']
    group node['ndb']['group']
    code <<-EOH
        set -e
        #{node['mysql']['bin_dir']}/mysql -h #{primary_mysql} -u #{node['ndb']['replication']['user']} -p#{node['ndb']['replication']['password']} -Nse "UPDATE rondb_replication.heartbeat_tbl SET active=#{active.to_s}, replica_id=#{my_server_id}, replica='#{my_ip}' WHERE primary_id=#{primary_server_id}"
    EOH
end

bash 'epoch-binlog-mapping-start' do
    user node['ndb']['user']
    group node['ndb']['group']
    code <<-EOH
        set -e
        # When we first setup the replication, the replication server id will be 0
        #{node['ndb']['scripts_dir']}/replication_configuration.sh -m #{primary_mysql} -u #{node['ndb']['replication']['user']} -p #{node['ndb']['replication']['password']} -r 0
    EOH
    only_if { active }
end

bash 'epoch-binlog-mapping-start' do
    user node['ndb']['user']
    group node['ndb']['group']
    code <<-EOH
        set -e
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e "START REPLICA"
    EOH
    only_if { active }
end

kagent_config 'rondb-heartbeater' do
    service "NDB"
    restart_agent false
    action :remove
end

systemd_unit "rondb-heartbeater.service" do
    action [:disable, :stop]
end

kagent_config 'rondb-monitor' do
    service "NDB"
    restart_agent false
    action :add
end

systemd_unit "rondb-monitor.service" do
    action [:enable, :start]
end