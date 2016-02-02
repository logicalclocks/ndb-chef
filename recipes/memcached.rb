require File.expand_path(File.dirname(__FILE__) + '/get_ndbapi_addrs')
require File.expand_path(File.dirname(__FILE__) + '/find_mysqld')

ndb_connectstring()
#generate_etc_hosts()

Chef::Log.info "Memcached for NDB"

theResource="memcached-installer"
service_name="memcached"

service service_name do
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

ndb_mysql_ndb theResource do
  action :nothing
end

my_ip = my_private_ip()
found_id=find_memcached_id(my_ip)

#hostId="ndbapi#{found_id}" 
#generate_hosts(hostId, my_ip)

for script in node[:memcached][:scripts]
  template "#{node[:ndb][:scripts_dir]}/#{script}" do
    source "#{script}.erb"
    owner node[:ndb][:user]
    group node[:ndb][:group]
    mode 0775
    variables({
                :node_id => found_id
              })
  end
end 

ndb_mysql_basic "mysqld_started" do
  wait_time 10
  action :wait_until_started
end


template "/etc/init.d/#{service_name}" do
  only_if { node[:ndb][:use_systemd] != "true" }
  source "#{service_name}.erb"
  owner node[:ndb][:user]
  group node[:ndb][:user]
  mode 0755
  variables({
              :ndb_dir => node[:ndb][:base_dir],
              :mysql_dir => node[:mysql][:base_dir],
              :connectstring => node[:ndb][:connectstring],
              :node_id => found_id 
            })
  notifies :install_memcached, "ndb_mysql_ndb[#{theResource}]", :immediately
  notifies :enable, "service[#{service_name}]"
  notifies :restart, "service[#{service_name}]"
end

case node[:platform_family]
  when "debian"
systemd_script = "/lib/systemd/system/#{service_name}.service"
  when "rhel"
systemd_script = "/usr/lib/systemd/system/#{service_name}.service" 
end

template systemd_script do
    only_if { node[:ndb][:use_systemd] == "true" }
    source "#{service_name}.service.erb"
    owner node[:ndb][:user]
    group node[:ndb][:user]
    mode 0755
    cookbook 'ndb'
    variables({
              :ndb_dir => node[:ndb][:base_dir],
              :mysql_dir => node[:mysql][:base_dir],
              :connectstring => node[:ndb][:connectstring],
              :node_id => found_id 
            })
    notifies :install_memcached, "ndb_mysql_ndb[#{theResource}]", :immediately
    notifies :enable, "service[#{service_name}]"
    notifies :restart, "service[#{service_name}]"
end


if node[:kagent][:enabled] == "true"

  kagent_config "memcached" do
   service "NDB"
   start_script "#{node[:ndb][:scripts_dir]}/memcached-start.sh"
   stop_script  "#{node[:ndb][:scripts_dir]}/memcached-stop.sh"
   log_file "#{node[:ndb][:log_dir]}/memcached_#{found_id}.out.log"
   pid_file "#{node[:ndb][:log_dir]}/memcached_#{found_id}.pid"
 end

end

ndb_start "memcached" do
end
