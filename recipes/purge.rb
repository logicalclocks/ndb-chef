# Stop all the service and remove all services
# TODO - should rename 'ndbd' as 'ndbmtd'. pkill wont work here fo it
daemons = %w{ndb_mgmd ndbdmtd mysqld memcached}
daemons.each { |d| 

  bash 'kill_running_service_#{d}' do
    user "root"
    ignore_failure true
    code <<-EOF
      service stop #{d}
      systemctl stop #{d}
      pkill -9 #{d}
    EOF
  end

  file "/etc/init.d/#{d}" do
    action :delete
    ignore_failure true
  end
  
  file "/usr/lib/systemd/system/#{d}.service" do
    action :delete
    ignore_failure true
  end
  file "/lib/systemd/system/#{d}.service" do
    action :delete
    ignore_failure true
  end
}

# Remove the MySQL binaries and MySQL Cluster data directories
directory node.ndb.root_dir do
  recursive true
  action :delete
  ignore_failure true
end

# TODO - don't know if wildcards are supported for deleting files/directories
#directory "#{node.mysql.base_dir}*" do

directory node.mysql.version_dir do
  recursive true
  action :delete
  ignore_failure true
end

link node.mysql.base_dir do
  action :delete
  ignore_failure true
end

directory Chef::Config.file_cache_path do
  recursive true
  action :delete
  ignore_failure true
end

homedir = node.ndb.user.eql?("root") ? "/root" : "/home/#{node.ndb.user}"
bash 'delete_marker_files' do
user "root"
ignore_failure true
code <<-EOF
 rm -f /etc/my.cnf
 rm -rf /etc/my.cnf.d
 rm -rf /etc/mysql
 rm -f #{Chef::Config.file_cache_path}/.ndb_downloaded
 rm -f /etc/profile.d/mysql_bin_path.sh
 rm -f /etc/default/irqbalance
 rm -f /etc/grub.d/07_rtai
 rm -rf #{homedir}/.ssh/config
 rm -rf #{homedir}/.ssh/.ndb_*
EOF
end


package "libaio remove" do
  case node.platform
  when 'redhat', 'centos'
    package_name 'libaio1'
  when 'ubuntu', 'debian'
    package_name 'libaio'
  end
 ignore_failure true
 action :purge
end
