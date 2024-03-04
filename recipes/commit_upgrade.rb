service "mysqld" do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
end

mycnf_conf = mysqld_configuration(is_tls_already_configured())
# override dist_upgrade_allowed since we are committed to the upgrade
mycnf_conf[:dist_upgrade_allowed] = 1

template "#{node['ndb']['root_dir']}/my.cnf" do
    source "my-ndb.cnf.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "0640"
    action :create
    variables(mycnf_conf)
notifies :restart, resources(:service => "mysqld"), :immediately
end