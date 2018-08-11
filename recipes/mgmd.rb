require File.expand_path(File.dirname(__FILE__) + '/get_ndbapi_addrs')


case node['platform']
when "ubuntu"
 if node['platform_version'].to_f <= 14.04
   node.override['ndb']['systemd'] = "false"
 end
end

if node['ndb']['systemd'] == false
   node.override['ndb']['systemd'] = "false"
end  


ndb_connectstring()

directory node['ndb']['mgm_dir'] do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "755"
end

found_id=-1
id=node['mgm']['id']
my_ip = my_private_ip()

for mgm in node['ndb']['mgmd']['private_ips']
  if my_ip.eql? mgm
    Chef::Log.info "Found matching IP address in the list of mgmd nodes: #{mgm}. ID= #{id}"
    found_id = id
  end
  id += 1
end 
Chef::Log.info "Found ID IS: #{found_id}"
Chef::Log.info "Backup with cron is: #{node['ndb']['cron_backup']}"

if found_id == -1
  raise "Could not find matching IP address #{my_ip} in the list of mgmd nodes: " + node['ndb']['mgmd']['private_ips'].join(",")
end

if !node['ndb']['local_backup_dir'].empty?
  directory node['ndb']['local_backup_dir'] do
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "700"
    action :create
  end
end

#
# Just copy the backup rotation script
#
cookbook_file "#{node['ndb']['scripts_dir']}/db_backup_rotation.sh" do
  source "db_backup_rotation.sh"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0700
end

#
# Source the native NDB backup script
#
template "#{node['ndb']['scripts_dir']}/native_ndb_backup.sh" do
    source "native_ndb_backup.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0700
end

#
# These are helper scripts for exapnding tables with on-disk columns
#
template "#{node['ndb']['scripts_dir']}/manage-disk-table.py" do
    source "manage-disk-table.py.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0700
end

template "#{node['ndb']['scripts_dir']}/create-disk-table.sh" do
    source "create-disk-table.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0700
end

#
# Install cron backup job on the node with the first ndb_mgmd
#
if found_id == node['mgm']['id'] && "#{node['ndb']['cron_backup']}" == "true"

  weekday = '*'
  if node['ndb']['backup_frequency'] == "weekly"
    weekday = '1'
  end
  hour = "#{node['ndb']['backup_time']}".match(":").pre_match
  minute = "#{node['ndb']['backup_time']}".match(":").post_match

  cron 'ndb_backup' do
    action :create
    minute minute
    hour hour
    weekday weekday
    user node['ndb']['user']
    command %W{
    #{node['ndb']['scripts_dir']}/native_ndb_backup.sh
  }.join(' ')
  end
  
  
end

datanodes= node['ndb']['ndbd']['private_ips'].join(" ")
for script in node['mgm']['scripts'] do
  template "#{node['ndb']['scripts_dir']}/#{script}" do
    source "#{script}.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0751
    variables({ :node_id => found_id,
        :datanodes => datanodes,
    })
  end
end 

service_name = "ndb_mgmd"


if node['ndb']['systemd'] != "true"


  service "#{service_name}" do
    provider Chef::Provider::Service::Init::Debian
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  template "/etc/init.d/#{service_name}" do
    source "#{service_name}.erb"
    owner "root"
    group "root"
    mode 0754
    variables({ :node_id => found_id })
if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
end
  end

else # systemd == true
  service "#{service_name}" do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end
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
    mode 0754
    cookbook 'ndb'
    variables({ :node_id => found_id })
if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
end
  end

end




# Need to call get_ndbapi_addrs to set them before instantiating config.ini
get_ndbapi_addrs()

template "#{node['ndb']['root_dir']}/config.ini" do
  source "config.ini.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0644
  action :create_if_missing
  variables({
              :num_client_slots => node['ndb']['num_ndb_slots_per_client'].to_i
            })
end

if node['kagent']['enabled'] == "true"

    kagent_config service_name do
      service "NDB"
      log_file "#{node['ndb']['log_dir']}/ndb_#{found_id}_out.log"
      config_file "#{node['ndb']['root_dir']}/config.ini"
      restart_agent false
      action :add
    end
end

if node['ndb']['systemd'] == "true"
  kagent_config "#{service_name}" do
    action :systemd_reload
  end
else
  ndb_start "ndb_mgmd" do
    action :start_if_not_running
  end
end

# Put public key of this mgmd-host in .ssh/authorized_keys of all ndbd and mysqld nodes
homedir = node['ndb']['user'].eql?("root") ? "/root" : "/home/#{node['ndb']['user']}"
Chef::Log.info "Home dir is #{homedir}. Generating ssh keys..."

kagent_keys "#{homedir}" do
  cb_user node['ndb']['user']
  cb_group node['ndb']['group']
  action :generate  
end  

kagent_keys "#{homedir}" do
  cb_user node['ndb']['user']
  cb_group node['ndb']['group']
  cb_name "ndb"
  cb_recipe "mgmd"  
  action :return_publickey
end  


#node['kagent']['upgrade'] - no need to restart the service, it's done already .
