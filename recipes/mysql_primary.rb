include_recipe "ndb::replication_configuration"

my_ip = my_private_ip()

my_server_id = get_mysql_server_id()

heartbeat_tbl = "#{node['ndb']['base_dir']}/replication_conf.sql"
template heartbeat_tbl do
    source "replication/replication_conf.sql.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "0600"
    variables({
        :server_id => my_server_id,
        :my_ip => my_ip,
    })
end

bash 'apply-configuration' do
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

bash 'conf-mysql-primary' do
    user node['ndb']['user']
    code <<-EOF
        set -e
        sed -i 's/ndb_log_bin[[:space:]]=[[:space:]]OFF/ndb_log_bin = ON/' #{node['ndb']['root_dir']}/my.cnf
        sed -i '/skip-slave-start/ s/^#*/#/' #{node['ndb']['root_dir']}/my.cnf
    EOF
    only_if "grep '^[[:space:]]*skip-slave-start|ndb_log_bin[[:space:]]*=[[:space:]]*OFF' #{node['ndb']['root_dir']}/my.cnf"
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