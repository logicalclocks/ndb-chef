private_ip=my_private_ip()
server_id = mysql_server_id()

grants = "#{node['ndb']['base_dir']}/replication_conf.sql"
template grants do
    source "replication/replication_conf.sql.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "0600"
    variables({
        :am_i_primary => node['ndb']['replication']['role'].casecmp?('primary'),
        :server_id => server_id,
        :my_ip => private_ip,
    })
end

template "#{node['ndb']['scripts_dir']}/replication_configuration.sh" do
    source "replication/replication_configuration.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0750
end

bash 'apply-configuration' do
    user node['ndb']['user']
    code <<-EOF
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e "source #{grants}"
    EOF
end

template "#{node['ndb']['scripts_dir']}/heartbeater.sh" do
    source "replication/heartbeater.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0750
end

template "#{node['ndb']['scripts_dir']}/replication_monitor.sh" do
    source "replication/replication_monitor.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0750
end