require File.expand_path(File.dirname(__FILE__) + '/get_ndbapi_addrs')


case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.ndb.systemd = "false"
 end
end

ndb_connectstring()

Chef::Log.info "Hostname is: #{node[:hostname]}"
Chef::Log.info "IP address is: #{node[:ipaddress]}"

directory node[:ndb][:data_dir] do
  owner node[:ndb][:user]
  group node[:ndb][:group]
  mode "755"
  action :create
  recursive true
end

my_ip = my_private_ip()

found_id = -1
id = 1
for ndbd in node[:ndb][:ndbd][:private_ips]
  if my_ip.eql? ndbd 
    Chef::Log.info "Found matching IP address in the list of data nodes: #{ndbd}. ID= #{id}"
    found_id = id
  end
  id += 1
end 
Chef::Log.info "ID IS: #{id}"

if found_id == -1
  raise "Ndbd: Could not find matching IP address in list of data nodes."
end

directory "#{node[:ndb][:data_dir]}/#{found_id}" do
  owner node[:ndb][:user]
  group node[:ndb][:group]
  mode "755"
  action :create
  recursive true
end


for script in node[:ndb][:scripts]
  template "#{node[:ndb][:scripts_dir]}/#{script}" do
    source "#{script}.erb"
    owner node[:ndb][:user]
    group node[:ndb][:group]
    mode 0655
    variables({ :node_id => found_id })
  end
end 


service_name = "ndbmtd"

service "#{service_name}" do
  case node[:ndb][:systemd]
    when "true"
    provider Chef::Provider::Service::Systemd
    else
    provider Chef::Provider::Service::Init::Debian
  end
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template "/etc/init.d/#{service_name}" do
  only_if { node[:ndb][:systemd] != "true" }
  source "ndbd.erb"
  owner node[:ndb][:user]
  group node[:ndb][:group]
  mode 0754
  variables({ :node_id => found_id })
  notifies :enable, "service[#{service_name}]"
  notifies :restart,"service[#{service_name}]", :immediately
end

case node[:platform_family]
  when "debian"
systemd_script = "/lib/systemd/system/#{service_name}.service"
  when "rhel"
systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
end

template systemd_script do
    only_if { node[:ndb][:systemd] == "true" }
    source "#{service_name}.service.erb"
    owner node[:ndb][:user]
    group node[:ndb][:group]
    mode 0754
    cookbook 'ndb'
    variables({ :node_id => found_id })
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]", :immediately
end



if node[:kagent][:enabled] == "true"
  Chef::Log.info "Trying to infer the #{service_name} ID by examining the local IP. If it matches the config.ini file, then we have our node."

  found_id = -1
  id = 1
  my_ip = my_private_ip()

  for ndbd in node[:ndb][:ndbd][:private_ips]
    if my_ip.eql? ndbd
      Chef::Log.info "Found matching IP address in the list of data nodes: #{ndbd} . ID= #{id}"
      found_id = id
    end
    id += 1
  end 

  Chef::Log.info "ID IS: #{id}"

  if found_id == -1
    Chef::Log.fatal "Could not find matching IP address is list of data nodes."
  end

  kagent_config "ndb" do
    service "NDB"
    start_script "#{node[:ndb][:scripts_dir]}/ndbd-start.sh"
    stop_script "#{node[:ndb][:scripts_dir]}/ndbd-stop.sh"
    init_script "#{node[:ndb][:scripts_dir]}/ndbd-init.sh"
    log_file "#{node[:ndb][:log_dir]}/ndb_#{found_id}_out.log"
    pid_file "#{node[:ndb][:log_dir]}/ndb_#{found_id}.pid"
  end

end


# Here we set interrupts to be handled by only the first CPU

if (node[:ndb][:interrupts_isolated_to_single_cpu] == "true") && (not ::File.exists?( "#{node[:mysql][:base_dir]}/.balance_irqs"))
  case node["platform_family"]
  when "debian"
    
    file "/etc/default/irqbalance" do 
      owner node[:hdfs][:user]
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
      touch #{node[:mysql][:base_dir]}/.balance_irqs
      EOF
      not_if { ::File.exists?( "#{node[:mysql][:base_dir]}/.balance_irqs" ) }
    end
    
  when "rhel"
    execute "set_interrupts_to_first_cpu" do
      user "root"
      code <<-EOF

      touch #{node[:mysql][:base_dir]}/.balance_irqs
      EOF
      not_if { ::File.exists?( "#{node[:mysql][:base_dir]}/.balance_irqs" ) }
    end

  end

end

homedir = node[:ndb][:user].eql?("root") ? "/root" : "/home/#{node[:ndb][:user]}"

# Add the mgmd hosts' public key, so that it can start/stop the ndbd on this node using passwordless ssh.
# ndb_mgmd_publickey "#{homedir}" do
#   action :get
# end
kagent_keys "#{homedir}" do
  cb_user "#{node[:ndb][:user]}"
  cb_group "#{node[:ndb][:group]}"
  cb_name "ndb"
  cb_recipe "mgmd"  
  action :get_publickey
end  


case node[:ndb][:systemd]
when "true"
  ndb_start "start-ndbd-systemd" do
    action :start_if_not_running_systemd
  end 
else
  ndb_start "start-ndbd-sysv" do
    action :start_if_not_running
  end 
end


