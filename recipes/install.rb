
#group node.ndb.group do
#  action :create
#  not_if "getent group #{node.ndb.group}"
#end

user node.ndb.user do
  supports :manage_home => true
  home "/home/#{node.ndb.user}"
  action :create
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node.ndb.user}"
end

# user node.ndb.user do
#   supports :manage_home => true
#   home "/home/#{node.ndb.user}"
#   action :create
#   system true
#   shell "/bin/bash"
#   not_if "getent passwd #{node.ndb.user}"
# end

group node.ndb.group do
  action :modify
#  members ["#{node.ndb.user}", "#{node.ndb.user}" ]
  members ["#{node.ndb.user}"]
  append true
end


directory node.ndb.dir do
  owner node.ndb.user
  group node.ndb.group
  mode "755"
  action :create
  recursive true
  not_if { File.directory?("#{node.ndb.dir}") }
end

directory node.ndb.version_dir do
  owner node.ndb.user
  group node.ndb.group
  mode "755"
  action :create
  recursive true
end


link node.ndb.base_dir do
  owner node.ndb.user
  group node.ndb.group
  to node.ndb.version_dir
end

directory "#{node.ndb.scripts_dir}/util" do
  owner node.ndb.user
  group node.ndb.user
  mode "755"
  action :create
  recursive true
end

directory node.ndb.log_dir do
  owner node.ndb.user
  group node.ndb.user
  mode "755"
  action :create
  recursive true
end

directory node.mysql.version_dir do
  owner node.ndb.user
  group node.ndb.user
  mode "755"
  action :create
  recursive true
end

directory node.ndb.shared_folder do
  owner node.ndb.user
  group node.ndb.user
  mode "755"
  action :create
  recursive true
end

package_url = node.ndb.package_url
Chef::Log.info "Downloading mysql cluster binaries from #{package_url}"
base_package_filename =  File.basename(node.ndb.package_url)
Chef::Log.info "Into file #{base_package_filename}"
base_package_dirname =  File.basename(base_package_filename, ".tar.gz")
ndb_package_dirname = "/tmp/#{base_package_dirname}"
cached_package_filename = "#{node.ndb.shared_folder}/#{base_package_filename}"

Chef::Log.info "You should find mysql cluster binaries it in:  #{cached_package_filename}"

# TODO - HTTP Proxy settings
remote_file cached_package_filename do
#  checksum node.ndb.checksum
  source package_url
  mode 0755
  action :create
end

if node.ndb.bind_cpus.eql? "true"
  directory "/etc/sysconfig" do
    owner "root"
    group "root"
    mode "755"
    action :create
  end

  file "/etc/sysconfig/irqbalance" do
    owner "root"
    action :delete
  end


  template "/etc/sysconfig/irqbalance" do
    source "irqbalance.ubuntu.erb"
    owner "root"
    group "root"
    mode 0655
  end
end

Chef::Log.info "Unzipping mysql cluster binaries into:  #{base_package_filename}"
Chef::Log.info "Moving mysql cluster binaries to:  #{node.mysql.version_dir}"
bash "unpack_mysql_cluster" do
    user "root"
    code <<-EOF
touch /tmp/.ndb_downloaded

tar -xzf #{cached_package_filename} -C /tmp
mv #{ndb_package_dirname}/* #{node.mysql.version_dir}
if [ -L #{node.mysql.base_dir}  ; then
 rm -rf #{node.mysql.base_dir}
fi

# http://www.slideshare.net/Severalnines/severalnines-my-sqlclusterpt2013
# TODO: If binding threads to CPU, run the following:
# echo '0' > /proc/sys/vm/swappiness
# echo 'vm.swappiness=0' >> /etc/sysctl.conf

chown -R #{node.ndb.user}:#{node.ndb.group} #{node.mysql.version_dir}
EOF
  not_if { ::File.exists?( "#{node.mysql.version_dir}/bin/ndbd" ) }
end



link node.mysql.base_dir do
  owner node.ndb.user
  group node.ndb.group
  to node.mysql.version_dir
end


template "/etc/profile.d/mysql_bin_path.sh" do
  user "root"
  mode 0755
  source "set_path.sh.erb"
end


template "#{node.ndb.scripts_dir}/util/kill-process.sh" do
  source "kill-process.sh.erb"
  owner node.ndb.user
  group node.ndb.user
  mode 0655
end



if "#{node.ndb.aws_enhanced_networking}" == "true" 
     case node['platform']
     when 'debian', 'ubuntu'
       ndb_ixgbevf "enhanced_ec2_networking" do
         action :install_ubuntu
       end
     when 'redhat', 'centos', 'fedora'
       ndb_ixgbevf "enhanced_ec2_networking" do
         action :install_redhat
       end
     end

end
