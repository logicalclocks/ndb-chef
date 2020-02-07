# This recipe is here to reconfigure the MySQL server to use TLS (if TLS is enabled)
# It cannot be done in the mysqld.rb recipe as we need MySQL to start Hopsworks to start the CA
# That's why this recipe is run after kagent::default (responsible for signing the certificates)
# and before the NN - the first service after Hopsworks which needs the database to be up and running 

if node['mysql']['tls'].casecmp?("true")

    group node['kagent']['certs_group'] do
        action :modify
        members [node['ndb']['user']]
        append true
        not_if { node['install']['external_users'].casecmp("true") == 0 }
    end

    service "mysqld" do
        provider Chef::Provider::Service::Systemd
        supports :restart => true, :stop => true, :start => true, :status => true
        action :nothing
    end
    
    found_id=find_service_id("mysqld", node['mysql']['id'])
    my_ip = my_private_ip()
    mysql_ip = node['mysql']['localhost'] == "true" ? "localhost" : my_ip
    template "#{node['ndb']['root_dir']}/my.cnf" do
        source "my-ndb.cnf.erb"
        owner node['ndb']['user']
        group node['ndb']['group']
        mode "0640"
        action :create
        variables({
            :mysql_id => found_id,
            :my_ip => mysql_ip,
            :mysql_tls => true
    })
    notifies :restart, resources(:service => "mysqld"), :immediately
    end
end