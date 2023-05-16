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

rdrs_log_file = "#{node['ndb']['rdrs']['log']['file_apth']}"
if node['ndb']['rdrs']['log']['file_apth'] == "" 
  rdrs_log_file = "#{node['ndb']['log_dir']}/rdrs.log"
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
   :rdrs_log_file => rdrs_log_file,
  })
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name), :immediately
  end
end

kagent_config "#{service_name}" do
  action :systemd_reload
  not_if "systemctl is-alive rdrs"
end

if node['kagent']['enabled'] == "true"
  kagent_config service_name do
    service "NDB"
    log_file "#{node['ndb']['root_dir']}/rdrs_config.json"
    config_file rdrs_log_file 
  end
end

if node['services']['enabled'] == "true"
  hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:8181"
  if node.attribute? "hopsworks"
      if node["hopsworks"].attribute? "https" and node["hopsworks"]['https'].attribute? ('port')
          hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node['hopsworks']['https']['port']}"
      end
  end
  crypto_dir = x509_helper.get_crypto_dir(node['ndb']['user'])
  kagent_hopsify "Generate x.509" do
      user node['ndb']['user']
      crypto_directory crypto_dir
      action :generate_x509
      hopsworks_alt_url hopsworks_alt_url
      not_if { node["kagent"]["enabled"] == "false" }
  end
  
  service "rdrs" do
      provider Chef::Provider::Service::Systemd
      supports :restart => true, :stop => true, :start => true, :status => true
      action :nothing
  end
  
  certificate = "#{crypto_dir}/#{x509_helper.get_certificate_bundle_name(node['ndb']['user'])}"
  private_key = "#{crypto_dir}/#{x509_helper.get_private_key_pkcs1_name(node['ndb']['user'])}"
  hops_ca = "#{crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}"
  template "#{node['ndb']['root_dir']}/rdrs_config.json" do
      source "rdrs_config.json.erb"
      owner node['ndb']['user']
      group node['ndb']['group']
      mode "0640"
      action :create
      variables({
          :enable_tls => true,
          :ndb_mgmd_ip => conn_str_split[0],
          :ndb_mgmd_port => conn_str_split[1],
          :root_ca_cert_file => hops_ca,
          :certificate_file => certificate,
          :private_key_file => private_key,
          :rdrs_log_file => rdrs_log_file,
  })
  notifies :restart, resources(:service => "rdrs"), :immediately
  end
end
