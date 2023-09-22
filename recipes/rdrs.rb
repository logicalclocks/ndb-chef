ndb_connectstring()

if node['ndb']['rdrs']['rondb']['mgmds'].empty?
  rondb_conn_str_arr=generate_rdrs_mgmd_conf(node['ndb']['connectstring'])
else
  rondb_conn_str_arr=generate_rdrs_mgmd_conf(node['ndb']['rdrs']['rondb']['mgmds'])
end

if node['ndb']['rdrs']['rondbmetadatacluster']['mgmds'].empty?
  rondb_metadata_cluster_conn_str_arr=rondb_conn_str_arr
else
  rondb_metadata_cluster_conn_str_arr=generate_rdrs_mgmd_conf(node['ndb']['rdrs']['rondbmetadatacluster']['mgmds'])
end

if node['ndb']['rdrs']['containerize'] == "true" 
  bash 'Setting-RDRS-Image' do
    user 'root'
    code <<-EOH
      set -e
      cd #{Chef::Config['file_cache_path']}
      rm -f docker-image-rdrs-#{node['ndb']['version']}.tar.gz
      wget -O docker-image-rdrs-#{node['ndb']['version']}.tar.gz  #{node['ndb']['rdrs']['container_image_url']}
      docker load < docker-image-rdrs-#{node['ndb']['version']}.tar.gz
    EOH
  end
end

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

service "#{service_name}" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :nothing
end

#Paths to certificates. The certificates may not exist
crypto_dir = x509_helper.get_crypto_dir(node['ndb']['user'])
certificate = "#{crypto_dir}/#{x509_helper.get_certificate_bundle_name(node['ndb']['user'])}"
private_key = "#{crypto_dir}/#{x509_helper.get_private_key_pkcs1_name(node['ndb']['user'])}"
hops_ca = "#{crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}"

hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:8181"
if node.attribute? "hopsworks"
  if node["hopsworks"].attribute? "https" and node["hopsworks"]['https'].attribute? ('port')
    hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node['hopsworks']['https']['port']}"
  end
end

kagent_hopsify "Generate x.509" do
  user node['ndb']['user']
  crypto_directory crypto_dir
  action :generate_x509
  hopsworks_alt_url hopsworks_alt_url
  not_if { node["kagent"]["enabled"] == "false" }
end

unless node['ndb']['rdrs']['key_url'].empty?
  remote_file "#{crypto_dir}/#{File.basename(node['ndb']['rdrs']['key_url'])}" do
    source node['ndb']['rdrs']['key_url']
    user node['ndb']['user']
    group node['ndb']['group']
    mode 0700
    action :create
  end
  private_key = "#{crypto_dir}/#{File.basename(node['ndb']['rdrs']['key_url'])}"
end

unless node['ndb']['rdrs']['certificate_url'].empty?
  remote_file "#{crypto_dir}/#{File.basename(node['ndb']['rdrs']['certificate_url'])}" do
    source node['ndb']['rdrs']['certificate_url']
    user node['ndb']['user']
    group node['ndb']['group']
    mode 0700
    action :create
  end
  certificate = "#{crypto_dir}/#{File.basename(node['ndb']['rdrs']['certificate_url'])}"
end

unless node['ndb']['rdrs']['ca_url'].empty?
  remote_file "#{crypto_dir}/#{File.basename(node['ndb']['rdrs']['ca_url'])}" do
    source node['ndb']['rdrs']['ca_url']
    user node['ndb']['user']
    group node['ndb']['group']
    mode 0700
    action :create
  end
  hops_ca = "#{crypto_dir}/#{File.basename(node['ndb']['rdrs']['ca_url'])}"
end

for script in node['ndb']['rdrs']['scripts']
  template "#{node['ndb']['scripts_dir']}/#{script}" do
    source "#{script}.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    action :create
    mode 0750
    variables({
      :crypto_dir => crypto_dir,
    })
  end
end

rdrs_log_file = "#{node['ndb']['rdrs']['log']['file_path']}"
if node['ndb']['rdrs']['log']['file_path'] == "" || node['ndb']['rdrs']['containerize'] == "true"  
  rdrs_log_file = "#{node['ndb']['log_dir']}/rdrs.log"
end

# template rdrs-config file
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
   :rondb_conn_str_arr => rondb_conn_str_arr,
   :rondb_metadata_cluster_conn_str_arr => rondb_metadata_cluster_conn_str_arr,
   :root_ca_cert_file => "",
   :certificate_file => "",
   :private_key_file => "",
   :rdrs_log_file => rdrs_log_file,
  })
  if node['services']['enabled'] == "true"
    notifies :enable, resources(:service => service_name), :immediately
  end
end

if node['ndb']['rdrs']['security']['enable_tls'] == "true"

  if node['services']['enabled'] == "true"
    template "#{node['ndb']['root_dir']}/rdrs_config.json" do
        source "rdrs_config.json.erb"
        owner node['ndb']['user']
        group node['ndb']['group']
        mode "0640"
        action :create
        variables({
            :enable_tls => true,
            :rondb_conn_str_arr => rondb_conn_str_arr,
            :rondb_metadata_cluster_conn_str_arr => rondb_metadata_cluster_conn_str_arr,
            :root_ca_cert_file => hops_ca,
            :certificate_file => certificate,
            :private_key_file => private_key,
            :rdrs_log_file => rdrs_log_file,
        })
        not_if { node["kagent"]["enabled"] == "false" }
    end
  end

end

kagent_config "#{service_name}" do
  action :systemd_reload
end

if node['kagent']['enabled'] == "true"
  kagent_config service_name do
    service "NDB"
    log_file "#{node['ndb']['root_dir']}/rdrs_config.json"
    config_file rdrs_log_file 
  end
end

if service_discovery_enabled()
  template "#{node['consul']['bin_dir']}/ping-rdrs.sh" do
    source "consul/ping-rdrs.sh.erb"
    owner node['consul']['user']
    group node['consul']['group']
    mode 0750
  end

  consul_service "Registering RDRS with Consul" do
    service_definition "consul/rdrs-consul.hcl.erb"
    reload_consul false
    action :register
  end
end
