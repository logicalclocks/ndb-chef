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

Chef::Log.info "Hostname is: #{node['hostname']}"
Chef::Log.info "IP address is: #{node['ipaddress']}"

#
# On Disk columns
#
if node['ndb']['nvme']['disks'].empty?
  directory node['ndb']['diskdata_dir'] do
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "750"
    action :create
  end
else
  directory "#{node['ndb']['nvme']['mount_base_dir']}" do
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "755"
    action :create
  end
end

index=0
mountPrefix="#{node['ndb']['nvme']['mount_base_dir']}/#{node['ndb']['nvme']['mount_disk_prefix']}"

for nvmeDisk in node['ndb']['nvme']['disks'] do
  if "#{node['ndb']['nvme']['format']}" == "true"
    bash 'format_nvme_disk' do
      user 'root'
      code <<-EOF
        set -e
        mkfs.ext4 -F #{nvmeDisk}
      EOF
    end
  end

  mountPoint="#{mountPrefix}#{index}"

  directory "#{mountPoint}" do
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "755"
    action :create
  end

  mount "#{mountPoint}" do
    device nvmeDisk
    fstype 'ext4'
  end

  diskDataDir="#{mountPoint}/#{node['ndb']['ndb_disk_columns_dir_name']}"
  directory "#{diskDataDir}" do
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "750"
    action :create
  end
  index+=1
end

directory node['ndb']['data_dir'] do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "755"
  action :create
end

my_ip = my_private_ip()

found_id = -1
id = 1

if node.attribute?(:ndb) && node['ndb'].attribute?(:ndbd) && node['ndb']['ndbd'].attribute?(:ips_ids) && !node['ndb']['ndbd']['ips_ids'].empty?
  for datanode in node['ndb']['ndbd']['ips_ids']
    theNode = datanode.split(":")
    if my_ip.eql? theNode[0]
      found_id = theNode[1]
      break
    end
  end
else
  for ndbd in node['ndb']['ndbd']['private_ips']
    if my_ip.eql? ndbd 
      Chef::Log.info "Found matching IP address in the list of data nodes: #{ndbd}. ID= #{id}"
      found_id = id
    end
    id += 1
  end
end
Chef::Log.info "ID IS: #{found_id}"

if found_id == -1
  raise "Ndbd: Could not find matching IP address in list of data nodes."
end

directory "#{node['ndb']['data_dir']}/#{found_id}" do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "755"
  action :create
end


for script in node['ndb']['scripts']
  template "#{node['ndb']['scripts_dir']}/#{script}" do
    source "#{script}.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0751
    variables({ :node_id => found_id })
  end
end 


service_name = "ndbmtd"

if node['ndb']['systemd'] != "true" 

service "#{service_name}" do
  provider Chef::Provider::Service::Init::Debian
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template "/etc/init.d/#{service_name}" do
  source "ndbd.erb"
  owner "root"
  group "root"
  mode 0754
  variables({ :node_id => found_id })
if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
end
  notifies :restart,"service[#{service_name}]", :immediately
end

else # systemd is true
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
    only_if { node['ndb']['systemd'] == "true" }
    source "#{service_name}.service.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0754
    cookbook 'ndb'
    variables({ :node_id => found_id })
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
  end
end

#
# Note: This will not do a rolling restart - it will bring down the DB.
#
  kagent_config "#{service_name}" do
    action :systemd_reload
    not_if "systemctl status ndbmtd"
  end

end

if node['kagent']['enabled'] == "true"
  Chef::Log.info "Trying to infer the #{service_name} ID by examining the local IP. If it matches the config.ini file, then we have our node."

  kagent_config service_name do
    service "NDB" # #{found_id}
    log_file "#{node['ndb']['log_dir']}/ndb_#{found_id}_out.log"
    restart_agent false    
    action :add
  end

end


# Here we set interrupts to be handled by only the first CPU

if (node['ndb']['interrupts_isolated_to_single_cpu'] == "true") && (not ::File.exists?( "#{node['mysql']['base_dir']}/.balance_irqs"))
 case node['platform_family']
  when "debian"
    
    file "/etc/default/irqbalance" do 
      owner node['hdfs']['user']
      action :delete
    end

    template "/etc/default/irqbalance" do
      source "irqbalance.ubuntu.erb"
      owner "root"
      mode 0644
    end

  # Need to isolate CPUs from handling interrupts using grub:
    # http://wiki.linuxcnc.org/cgi-bin/wiki.pl?The_Isolcpus_Boot_Parameter_And_GRUB2
    # Test using strees:
    #  apt-get install stress && stress -c 24
    # Sometimes you may need to disable hyper-threading in bios, restart, then restart and re-enable
    # hyperthreading and it works
    template "/etc/grub.d/07_rtai" do
      source "07_rtai.erb"
      owner "root"
      mode 0644
    end

    execute "set_interrupts_to_first_cpu" do
      user "root"
      code <<-EOF
          service irqbalance stop
          source /etc/default/irqbalance 
          irqbalance
          update-grub
      touch #{node['mysql']['base_dir']}/.balance_irqs
      EOF
      not_if { ::File.exists?( "#{node['mysql']['base_dir']}/.balance_irqs" ) }
    end
    
  when "rhel"
    execute "set_interrupts_to_first_cpu" do
      user "root"
      code <<-EOF

      touch #{node['mysql']['base_dir']}/.balance_irqs
      EOF
      not_if { ::File.exists?( "#{node['mysql']['base_dir']}/.balance_irqs" ) }
    end

  end

end

homedir = node['ndb']['user'].eql?("root") ? "/root" : "/home/#{node['ndb']['user']}"

# Add the mgmd hosts' public key, so that it can start/stop the ndbd on this node using passwordless ssh.
kagent_keys "#{homedir}" do
  cb_user "#{node['ndb']['user']}"
  cb_group "#{node['ndb']['group']}"
  cb_name "ndb"
  cb_recipe "mgmd"  
  action :get_publickey
end  

case node['ndb']['systemd']
when "true"
  ndb_start "start-ndbd-systemd" do
    action :start_if_not_running_systemd
  end 
else
  ndb_start "start-ndbd-sysv" do
    action :start_if_not_running
  end 
end

#
# Source the native NDB backup cleaner script
#
template "#{node['ndb']['scripts_dir']}/ndb_backup_cleaner.sh" do
    source "ndb_backup_cleaner.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0500
end

#
# Schedule the cleaner
#
if node['ndb']['cron_backup'].eql? "true"
  cron "ndb_backup_cleaner" do
    action :create
    minute '0'
    hour '4'
    day '*'
    month '*'
    only_if do File.exist?("#{node['ndb']['scripts_dir']}/ndb_backup_cleaner.sh") end
  end
end
