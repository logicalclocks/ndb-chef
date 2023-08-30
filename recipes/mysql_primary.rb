include_recipe 'ndb::replication_common'

my_ip = my_private_ip()
primary_ips = node['ndb']['mysql_primary']['private_ips']
idx = primary_ips.sort().index(my_ip)
primary_cluster_id = node['ndb']['replication']['primary-cluster-id'].to_i
my_server_id = primary_cluster_id + idx

heartbeat_tbl = "#{node['ndb']['base_dir']}/heartbeat_tbl.sql"
template heartbeat_tbl do
    source "replication/heartbeat_tbl.sql.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "0600"
    variables({
        :server_id => my_server_id,
        :my_ip => my_ip
    })
end

bash 'create-populate-heartbeat_tbl' do
    user node['ndb']['user']
    code <<-EOF
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e "source #{heartbeat_tbl}"
    EOF
end

# make sure we do not run replication in case we are switching role
bash 'stop-replica' do
    user node['ndb']['user']
    code <<-EOF
    set -e
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e "STOP REPLICA"
    EOF
end

bash 'comment-out-replica-start' do
    user node['ndb']['user']
    code <<-EOF
        set -e
        sed -i '/skip-slave-start/ s/^#*/#/' #{node['ndb']['root_dir']}/my.cnf
    EOF
    only_if "grep '^[[:space:]]*skip-slave-start' #{node['ndb']['root_dir']}/my.cnf"
    notifies :restart, "systemd_unit[mysqld.service]"
end

systemd_unit "mysqld.service" do
    action :nothing
end

# make sure there is no entry in the heartbeat table where I am replica ie switching role
bash 'delete-replica-with-my-id' do
    user node['ndb']['user']
    group node['ndb']['group']
    code <<-EOF
        set -e
        #{node['mysql']['bin_dir']}/mysql -h #{my_ip} -u #{node['ndb']['replication']['user']} -p#{node['ndb']['replication']['password']} -Nse "DELETE FROM rondb_replication.heartbeat_tbl WHERE replica_id=#{my_server_id}"
    EOF
end

systemd_unit "rondb-monitor.service" do
    action [:disable, :stop]
end

kagent_config 'rondb-monitor' do
    service "NDB"
    restart_agent false
    action :remove
end

kagent_config 'rondb-heartbeater' do
    service "NDB"
    restart_agent false
    action :add
end

systemd_unit "rondb-heartbeater.service" do
    action [:enable, :start]
end