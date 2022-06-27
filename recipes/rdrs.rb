ndb_connectstring()

ndb_connectstring()
conn_str = "#{node['ndb']['connectstring']}"
conn_str_split = conn_str.split(/:/, 2)


deps = ""
if exists_local("ndb", "ndbd") 
  deps = "ndbmtd.service"
end  

service_name = "rdrs"
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
  mode 0755
  cookbook 'ndb'
  variables({
      :deps => deps,
      :pid_file => "#{node['ndb']['log_dir']}/rdrs.pid"
   })
end

for script in node['ndb']['rdrs']['scripts']
  template "#{node['ndb']['scripts_dir']}/#{script}" do
    source "#{script}.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0750
  end
end

service "#{service_name}" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

template "#{node['ndb']['root_dir']}/rdrs_config.json" do
  source "rdrs_config.json.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "0640"
  action :create
  variables({
   # Here is always false, as this recipe is run before certificates are available
   # if rdrs/tls is enabled, the file will be re-templated later
   :enable_tls => false,
   :ndb_mgmd_ip => conn_str_split[0],
   :ndb_mgmd_port => conn_str_split[1],
   :root_ca_cert_file => "",
   :certificate_file => "",
   :private_key_file => "",
  })
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name), :immediately
  end
end

kagent_config "#{service_name}" do
  action :systemd_reload
  not_if "systemctl is-alive rdrs"
end
