#
# Node exporter installation
# 

base_package_filename = File.basename(node['ndb']['mysqld_exporter']['url'])
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

remote_file cached_package_filename do
  source node['ndb']['mysqld_exporter']['url']
  owner "root"
  mode "0644"
  action :create_if_missing
end

mysqld_exporter_downloaded= "#{node['ndb']['mysqld_exporter']['home']}/.mysqld_exporter.extracted_#{node['ndb']['mysqld_exporter']['version']}"
# Extract node_exporter 
bash 'extract_mysqld_exporter' do
  user "root"
  code <<-EOH
    tar -xf #{cached_package_filename} -C #{node['ndb']['dir']}
    chown -R #{node['ndb']['user']}:#{node['ndb']['group']} #{node['ndb']['mysqld_exporter']['home']}
    chmod 750 #{node['ndb']['mysqld_exporter']['home']}
    touch #{mysqld_exporter_downloaded}
    chown #{node['ndb']['user']} #{mysqld_exporter_downloaded}
  EOH
  not_if { ::File.exists?( mysqld_exporter_downloaded ) }
end

link node['ndb']['mysqld_exporter']['base_dir'] do
   owner node['ndb']['user']
   group node['ndb']['group']
   to node['ndb']['mysqld_exporter']['home']
end

case node['platform_family']
when "rhel"
  systemd_script = "/usr/lib/systemd/system/mysqld_exporter.service" 
else
  systemd_script = "/lib/systemd/system/mysqld_exporter.service"
end

service "mysqld_exporter" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template systemd_script do
  source "mysqld_exporter.service.erb"
  owner "root"
  group "root"
  mode 0664
  if node['services']['enabled'] == "true"
    notifies :enable, "service[mysqld_exporter]"
  end
  notifies :restart, "service[mysqld_exporter]"
end

kagent_config "mysqld_exporter" do
  action :systemd_reload
end

if node['kagent']['enabled'] == "true"
   kagent_config "mysqld_exporter" do
     service "Monitoring"
     restart_agent false
   end
end

if service_discovery_enabled()
  # Register MySQL exporter with Consul
  consul_service "Registering MySQL exporter with Consul" do
    service_definition "mysql-exporter-consul.hcl.erb"
    restart_consul false
    action :register
  end
end 