if node['ndb']['systemd'] == false
   node.override['ndb']['systemd'] = "false"
end  

ndb_connectstring()

Chef::Log.info "Hostname is: #{node['hostname']}"
Chef::Log.info "IP address is: #{node['ipaddress']}"

#
# On Disk columns
#
if node['ndb']['nvme']['devices'].empty?
  directory node['ndb']['data_volume']['on_disk_columns'] do
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "750"
    recursive true
    action :create
  end

  link node['ndb']['diskdata_dir'] do
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "750"
    to node['ndb']['data_volume']['on_disk_columns']
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

volumes = node['ndb']['nvme']['devices']

for nvmeDisk in volumes do
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

directory node['ndb']['data_volume']['data_dir'] do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  recursive true
  action :create
end

bash 'Move RonDB data to data volume' do
  user 'root'
  code <<-EOH
    set -e
    mv -f #{node['ndb']['data_dir']}/* #{node['ndb']['data_volume']['data_dir']}
    rm -rf #{node['ndb']['data_dir']}
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(node['ndb']['data_dir'])}
  not_if { File.symlink?(node['ndb']['data_dir'])}
end

link node['ndb']['data_dir'] do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  to node['ndb']['data_volume']['data_dir']
end

found_id = find_service_id("ndbd", 1)
directory "#{node['ndb']['data_dir']}/#{found_id}" do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  action :create
end

cookbook_file "#{node['ndb']['scripts_dir']}/ndbd_env_variables" do
  source "ndbd_env_variables"
  user node['ndb']['user']
  group node['ndb']['group']
  mode 0750
end

for script in node['ndb']['scripts']
  template "#{node['ndb']['scripts_dir']}/#{script}" do
    source "#{script}.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0750
    variables({ :node_id => found_id })
  end
end 

deps = ""
if exists_local("ndb", "mgmd") 
  deps = "ndb_mgmd.service"
end  

service_name = "ndbmtd"

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
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0754
  variables({
              :deps => deps,
              :node_id => found_id
  })
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name)
  end
end

#
# Note: This will not do a rolling restart - it will bring down the DB.
#
kagent_config "#{service_name}" do
  action :systemd_reload
  not_if "systemctl is-alive ndbmtd"
end

kagent_config service_name do
  service "NDB" # #{found_id}
  log_file "#{node['ndb']['log_dir']}/ndb_#{found_id}_out.log"
  restart_agent false    
  action :add
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

kagent_config "#{service_name}" do
  action :systemd_reload
  not_if "systemctl is-alive ndbmtd"
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
