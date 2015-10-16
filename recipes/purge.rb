# Stop all the services

bash 'kill_running_services' do
user "root"
ignore_failure :true
code <<-EOF
 service stop ndb_mgmd
 service stop ndbmtd
 service stop mysqld
 service stop memcached
 killall -9 ndb_mgmd
 killall -9 ndbmtd
 killall -9 mysqld
 killall -9 memcached
EOF
end

# Remove all services
daemons = %w{ndb_mgmd ndbd mysqld memcached}
daemons.each { |d| 
file "/etc/init.d/#{d}" do
  action :delete
  ignore_failure :true
end
}

# Remove the MySQL binaries and MySQL Cluster data directories
directory node[:ndb][:root_dir] do
  recursive true
  action :delete
  ignore_failure :true
end

# TODO - don't know if wildcards are supported for deleting files/directories
#directory "#{node[:mysql][:base_dir]}*" do

directory node[:mysql][:version_dir] do
  recursive true
  action :delete
  ignore_failure :true
end

link node[:mysql][:base_dir] do
  action :delete
  ignore_failure :true
end

directory Chef::Config[:file_cache_path] do
  recursive true
  action :delete
  ignore_failure :true
end

homedir = node[:ndb][:user].eql?("root") ? "/root" : "/home/#{node[:ndb][:user]}"
bash 'delete_marker_files' do
user "root"
ignore_failure :true
code <<-EOF
 rm -f #{Chef::Config[:file_cache_path]}/.ndb_downloaded
 rm -f /etc/profile.d/mysql_bin_path.sh
 rm -f /etc/default/irqbalance
 rm -f /etc/grub.d/07_rtai
 rm -rf #{homedir}/.ssh/config
EOF
end


package "libaio remove" do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'libaio1'
  when 'ubuntu', 'debian'
    package_name 'libaio'
  end
 ignore_failure :true
 action :purge
end
