action :install_grants do

  ndb_waiter "wait_ndb_started" do
    action :wait_until_cluster_ready
    only_if { node['ndb']['enabled'] == "true" }
  end

  ndb_mysql_basic "mysqld_start_grants" do
    wait_time 20
    remove_mycnf 1
    action :wait_until_started
  end

  grants_path = "#{node['ndb']['base_dir']}/grants.sql"
  template grants_path do
    source "grants.sql.erb"
    owner node['ndb']['user']
    mode "0600"
    action :create_if_missing
  end

  exec= node['ndb']['scripts_dir'] + "/mysql-client.sh"
  bash 'run_grants' do
    user node['ndb']['user']
    environment ({
      'MYSQL_HOME' => node['ndb']['root_dir']
    })
    code <<-EOF
     #{exec} -e "source #{grants_path}"
    EOF
    not_if "#{node['mysql']['base_dir']}/bin/mysql -u root --skip-password -S #{node['ndb']['mysql_socket']} -e \"SELECT user FROM mysql.user WHERE user=\"#{node['mysql']['user']}\"\"", :user => "#{node['ndb']['user']}"
  end
  new_resource.updated_by_last_action(true)
end

action :wait_until_started do

  # mysql_install_db makes a copy of the my.cnf file in /etc/mysql. Remove it.
  # Useful in dirty machines on which a mysql server was installed before.
  bash "remove_mycnf_#{new_resource.name}" do
    user "root"
    code <<-EOF
      rm -f /etc/mysql/my.cnf  
    EOF
    only_if { new_resource.remove_mycnf == 1 }
  end

  ret_delay = 5
  num_retry = new_resource.wait_time / ret_delay 

  bash 'wait_mysqld_started' do
    user "root"
    retries num_retry
    retry_delay ret_delay 
    code <<-EOF
      #{node['mysql']['base_dir']}/bin/mysqladmin -u root -S #{node['ndb']['mysql_socket']} status
    EOF
  end

  Chef::Log.info "MySQL Server has started."
  new_resource.updated_by_last_action(false)
end
