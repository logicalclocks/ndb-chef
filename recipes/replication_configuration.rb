grants = "#{node['ndb']['base_dir']}/replication_grants.sql"
template grants do
    source "replication/replication_grants.sql.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode "0600"
end

bash 'apply-replication-grants' do
    user node['ndb']['user']
    code <<-EOF
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e "source #{grants}"
    EOF
end

template "#{node['ndb']['scripts_dir']}/replication_configuration.sh" do
    source "replication/replication_configuration.sh.erb"
    owner node['ndb']['user']
    group node['ndb']['group']
    mode 0750
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

case node["platform_family"]
when "debian"
    systemd_dir = "/lib/systemd/system"
when "rhel"
    systemd_dir = "/usr/lib/systemd/system"
end

template "#{systemd_dir}/rondb-heartbeater.service" do
    source "replication/rondb-heartbeater.service.erb"
    owner 'root'
    group 'root'
    mode 0744
end

template "#{systemd_dir}/rondb-monitor.service" do
    source "replication/rondb-monitor.service.erb"
    owner 'root'
    group 'root'
    mode 0744
end