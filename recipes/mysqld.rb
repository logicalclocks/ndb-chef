require 'time'

ndb_connectstring()

case node['platform_family']
when "debian"
  package  "libaio1" do
    retries 10
    retry_delay 30
  end
when "rhel"
  package ["libaio", "numactl"] do
    retries 10
    retry_delay 30
  end
end

directory node['ndb']['data_volume']['mysql_server_dir'] do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0700
  action :create
  not_if { File.directory?(node['ndb']['data_volume']['mysql_server_dir']) }
end

bash 'Move MySQL data directory to data volume' do
  user 'root'
  code <<-EOH
    set -e
    mv -f #{node['ndb']['mysql_server_dir']}/* #{node['ndb']['data_volume']['mysql_server_dir']}
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(node['ndb']['mysql_server_dir']) }
  not_if { File.symlink?(node['ndb']['mysql_server_dir']) }
end

bash 'Delete MySQL data directory' do
  user 'root'
  code <<-EOH
    set -e
    rm -rf #{node['ndb']['mysql_server_dir']}
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(node['ndb']['mysql_server_dir'])}
  not_if { File.symlink?(node['ndb']['mysql_server_dir'])}
end

link node['ndb']['mysql_server_dir'] do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0700
  to node['ndb']['data_volume']['mysql_server_dir']
end

found_id=find_service_id("mysqld", node['mysql']['id'])

for script in node['mysql']['scripts']
  template "#{node['ndb']['scripts_dir']}/#{script}" do
    source "#{script}.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0750
    variables({
      :node_id => found_id
    })
  end
end

deps = node['install']['systemd']['after']
if exists_local("ndb", "ndbd") 
  deps += " ndbmtd.service"
end  
service_name = "mysqld"

case node['platform_family']
when "debian"
  systemd_script = "/lib/systemd/system/#{service_name}.service"
when "rhel"
  systemd_script = "/usr/lib/systemd/system/#{service_name}.service"
end

template systemd_script do
  source "#{service_name}.service.erb"
  owner "root"
  group "root"
  mode 0755
  cookbook 'ndb'
  variables({
      :deps => deps
   })
end

service "#{service_name}" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

server_id = mysql_server_id(my_private_ip(), node['ndb']['replication']['cluster-id'])

template "#{node['ndb']['root_dir']}/my.cnf" do
  source "my-ndb.cnf.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "0640"
  action :create
  variables({
   :mysql_id => found_id,
   # Here is always false, as this recipe is run before certificates are available
   # if mysql/tls is enabled, the file will be re-templated later
   :mysql_tls => false,
   :timezone => Time.now.strftime("%:z"),
   :server_id => server_id,
   :am_i_primary => node['ndb']['replication']['role'].casecmp?('primary')
  })
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name), :immediately
  end
end

# --force causes mysql_install_db to run even if DNS does not work. In that case, grant table entries that normally use host names will use IP addresses.
bash 'mysql_install_db' do
  user "root"
  environment ({
    'MYSQL_HOME' => node['ndb']['root_dir']
  })  
  cwd node['mysql']['base_dir']
  code <<-EOF
    set -e
    # Do NOT delete the whole directory as it is a symlink to the data drive
    rm -rf #{node['ndb']['mysql_server_dir']}/*

    ./bin/mysqld --defaults-file=#{node['ndb']['root_dir']}/my.cnf --initialize-insecure --explicit_defaults_for_timestamp

    # sanity check to set ownership of files to 'mysql' user
    chown -R #{node['ndb']['user']}:#{node['ndb']['group']} #{node['ndb']['mysql_server_dir']}
  EOF
  only_if { node['mysql']['initialize'].casecmp?("true") }
  not_if "#{node['mysql']['base_dir']}/bin/mysql -u root --skip-password -S #{node['ndb']['mysql_socket']} -e \"show databases\" | grep mysql "
end

kagent_config "#{service_name}" do
  action :systemd_reload
  not_if "systemctl is-alive ndbmtd"
end

ndb_mysql_basic "create_users_grants" do
  action :install_grants
end

# Dont leave the username/passwords to mysql lying around in file in the cache
file "#{Chef::Config.file_cache_path}/grants.sql" do
  owner "root"
  action :delete
end

nvmeDisksMountPoints="[]"
if !node['ndb']['nvme']['devices'].empty?
  nvmeDisks = node['ndb']['nvme']['devices'].each_with_index.map do |e, i|
     "#{node['ndb']['nvme']['mount_base_dir']}/#{node['ndb']['nvme']['mount_disk_prefix']}#{i}/#{node['ndb']['ndb_disk_columns_dir_name']}"
  end
  nvmeDisksMountPoints = "['#{nvmeDisks.join("', '")}']"
end

#
# These are helper scripts for exapnding tables with on-disk columns
#
template "#{node['ndb']['scripts_dir']}/manage-disk-table.py" do
    source "manage-disk-table.py.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    variables ({ :nvmeDisksDataDirs => nvmeDisksMountPoints})
    mode 0700
end

template "#{node['ndb']['scripts_dir']}/create-disk-table.sh" do
    source "create-disk-table.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0700
end

template "#{node['ndb']['scripts_dir']}/drop-disk-table.sh" do
    source "drop-disk-table.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0700
end

kagent_config service_name do
  service "NDB" # #{found_id}
  log_file "#{node['ndb']['log_dir']}/mysql_#{found_id}_out.log"
  restart_agent false
  action :add
end

homedir = node['ndb']['user'].eql?("root") ? "/root" : conda_helpers.get_user_home(node['ndb']['user'])
kagent_keys "#{homedir}" do
  cb_user "#{node['ndb']['user']}"
  cb_group "#{node['ndb']['group']}"
  cb_name "ndb"
  cb_recipe "mgmd"
  action :get_publickey
end

kagent_config "#{service_name}" do
    action :systemd_reload
    not_if "systemctl is-alive ndbmtd"
end

# Download and install mysqld_exporter
include_recipe "ndb::mysqld_exporter"

if service_discovery_enabled()
  template "#{node['consul']['bin_dir']}/ping-mysqld.sh" do
    source "consul/ping-mysqld.sh.erb"
    owner node['consul']['user']
    group node['consul']['group']
    mode 0750
  end

  # Register MySQL with Consul
  consul_service "Registering MySQL with Consul" do
    service_definition "mysql-consul.hcl.erb"
    reload_consul false
    action :register
  end
end

if conda_helpers.is_upgrade
  kagent_config "#{service_name}" do
    action :systemd_reload
  end
end

# Grant permissions to feature store admin user
grants_path = "#{node['ndb']['base_dir']}/featurestore_grants.sql"
template grants_path do
  source "featurestore_grants.sql.erb"
  owner node['ndb']['user']
  mode "0600"
  action :create_if_missing
  only_if {node['mysql']['onlinefs'].casecmp?("true")}
end

exec= node['ndb']['scripts_dir'] + "/mysql-client.sh"
bash 'run_featurestore_grants' do
  user node['ndb']['user']
  code <<-EOF
   #{exec} -e "source #{grants_path}"
  EOF
  only_if {node['mysql']['onlinefs'].casecmp?("true")}
end
