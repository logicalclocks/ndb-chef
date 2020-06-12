ndb_connectstring()

case node['platform_family']
when "debian"
  package  "libaio1"
when "rhel"
  package ["libaio", "numactl"] 
end

directory node['ndb']['mysql_server_dir'] do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0700
  action :create
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

deps = ""
if exists_local("ndb", "ndbd") 
  deps = "ndbmtd.service"
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
      :deps => deps,
      :pid_file => "#{node['ndb']['log_dir']}/mysql_#{found_id}.pid"
   })
end

service "#{service_name}" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

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
   :mysql_tls => false
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
    rm -rf #{node['ndb']['mysql_server_dir']}

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
if !node['ndb']['nvme']['disks'].empty?
  nvmeDisks = node['ndb']['nvme']['disks'].each_with_index.map do |e, i|
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

if node['ndb']['enabled'] == "true"
  ndb_mysql_ndb "install" do
   action :install_distributed_privileges
  end
end

if node['kagent']['enabled'] == "true"
  kagent_config service_name do
    service "NDB" # #{found_id}
    log_file "#{node['ndb']['log_dir']}/mysql_#{found_id}_out.log"
    restart_agent false
    action :add
  end
end

homedir = node['ndb']['user'].eql?("root") ? "/root" : "/home/#{node['ndb']['user']}"
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

if conda_helpers.is_upgrade
  kagent_config "#{service_name}" do
    action :systemd_reload
  end
end


