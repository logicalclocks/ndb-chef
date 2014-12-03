require File.expand_path(File.dirname(__FILE__) + '/get_ndbapi_addrs')
libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')

ndb_connectstring()
#generate_etc_hosts()


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
#hostId=""
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

#hostId="ndbd#{found_id}" 
#generate_hosts(hostId, my_ip)

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

service "ndbd" do
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template "/etc/init.d/ndbd" do
  source "ndbd.erb"
  owner node[:ndb][:user]
  group node[:ndb][:group]
  mode 0754
  variables({ :node_id => found_id })
  notifies :enable, "service[ndbd]"
  notifies :restart,"service[ndbd]", :immediately
end

if node[:kagent][:enabled] == "true"
  Chef::Log.info "Trying to infer the ndbd ID by examining the local IP. If it matches the config.ini file, then we have our node."

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
