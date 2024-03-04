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
        not_if { node["kagent"]["enabled"] == "false" }
    end

    service "mysqld" do
        provider Chef::Provider::Service::Systemd
        supports :restart => true, :stop => true, :start => true, :status => true
        action :nothing
    end

    mycnf_conf = mysqld_configuration(true)

    template "#{node['ndb']['root_dir']}/my.cnf" do
        source "my-ndb.cnf.erb"
        owner node['ndb']['user']
        group node['ndb']['group']
        mode "0640"
        action :create
        variables(mycnf_conf)
    notifies :restart, resources(:service => "mysqld"), :immediately
    end
end
