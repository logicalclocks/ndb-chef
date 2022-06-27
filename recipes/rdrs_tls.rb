# This recipe is here to reconfigure the rest api server to use TLS (if TLS is enabled)
# This recipe is run after kagent::default (responsible for signing the certificates)


ndb_connectstring()
conn_str = "#{node['ndb']['connectstring']}"
conn_str_split = conn_str.split(/:/, 2)

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
})
notifies :restart, resources(:service => "rdrs"), :immediately
end

