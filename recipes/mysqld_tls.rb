# This recipe is here to reconfigure the MySQL server to use TLS (if TLS is enabled)
# It cannot be done in the mysqld.rb recipe as we need MySQL to start Hopsworks to start the CA
# That's why this recipe is run after kagent::default (responsible for signing the certificates)
# and before the NN - the first service after Hopsworks which needs the database to be up and running 

if node['mysql']['tls'].casecmp?("true")
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
        not_if { conda_helpers.is_upgrade || node["kagent"]["enabled"] == "false" }
    end

    service "mysqld" do
        provider Chef::Provider::Service::Systemd
        supports :restart => true, :stop => true, :start => true, :status => true
        action :nothing
    end
    
    found_id=find_service_id("mysqld", node['mysql']['id'])
    certificate = "#{crypto_dir}/#{x509_helper.get_certificate_bundle_name(node['ndb']['user'])}"
    key = "#{crypto_dir}/#{x509_helper.get_private_key_pkcs1_name(node['ndb']['user'])}"
    hops_ca = "#{crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}"
    template "#{node['ndb']['root_dir']}/my.cnf" do
        source "my-ndb.cnf.erb"
        owner node['ndb']['user']
        group node['ndb']['group']
        mode "0640"
        action :create
        variables({
            :mysql_id => found_id,
            :mysql_tls => true,
            :certificate => certificate,
            :key => key,
            :hops_ca => hops_ca
    })
    notifies :restart, resources(:service => "mysqld"), :immediately
    end
end
