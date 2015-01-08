
action :install_distributed_privileges do
  # load the users using distributed privileges
  # http://dev.mysql.com/doc/refman/5.5/en/mysql-cluster-privilege-distribution.html
new_resource.updated_by_last_action(false)
if node[:ndb][:enabled] == "true"

  ndb_waiter "wait_mysql_started" do
     action :wait_until_cluster_ready
  end

  ndb_mysql_basic "mysqld_start_hop_install" do
    wait_time 10
    action :wait_until_started
  end

  bash "mysql-install-hop" do
    user node[:ndb][:user]
    code <<-EOF
    #{node[:ndb][:scripts_dir]}/mysql-client.sh hop < #{Chef::Config[:file_cache_path]}/hop.sql
    EOF
    new_resource.updated_by_last_action(true)
    not_if "#{node[:ndb][:scripts_dir]}/mysql-client.sh hop -e \"SELECT 1 FROM cluster limit 1;\""
  end


  distusers = "#{node[:mysql][:version_dir]}/share/ndb_dist_priv.sql"
  bash 'create_distributed_privileges' do
    user node[:ndb][:user]
    code <<-EOF
      #{node[:ndb][:scripts_dir]}/mysql-client.sh < #{distusers}
     # Test that it works
     #{node[:ndb][:scripts_dir]}/mysql-client.sh -e "CALL mysql.mysql_cluster_move_privileges();" 
     echo "Verifying successful conversion of tables.."
     #{node[:ndb][:scripts_dir]}/mysql-client.sh -e "SELECT CONCAT('Conversion ', IF(mysql.mysql_cluster_privileges_are_distributed(), 'succeeded', 'failed'), '.') AS Result;" | grep "Conversion succeeded" 
    EOF
    new_resource.updated_by_last_action(true)
    not_if "#{node[:ndb][:scripts_dir]}/mysql-client.sh -e \"SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME LIKE 'mysql_cluster%';\"  | grep mysql_cluster"
  end

end

end

action :install_memcached do
new_resource.updated_by_last_action(false)
if node[:ndb][:enabled] == "true"

  ndb_mysql_basic "mysqld_start_memcached_install" do
    wait_time 10
    action :wait_until_started
  end

  memcached_sql = "#{node[:mysql][:version_dir]}/share/memcache-api/ndb_memcache_metadata.sql"
  #  http://dev.mysql.com/doc/ndbapi/en/ndbmemcache-overview.html
  bash 'install_memcached_tables' do
    user node[:ndb][:user]
    code <<-EOF
     #{node[:ndb][:scripts_dir]}/mysql-client.sh < #{memcached_sql}
    EOF
    new_resource.updated_by_last_action(true)
    not_if "#{node[:ndb][:scripts_dir]}/mysql-client.sh -e \"SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='ndbmemcache';\" | grep ndbmemcache"
  end

end

end



action :install_hops do

new_resource.updated_by_last_action(false)
if node[:ndb][:enabled] == "true"

  ndb_waiter "wait_mysql_started" do
     action :wait_until_cluster_ready
  end

  ndb_mysql_basic "mysqld_start_hop_install" do
    wait_time 10
    action :wait_until_started
  end

  bash "mysql-install-hops" do
    user node[:ndb][:user]
    code <<-EOF
    #{node[:ndb][:scripts_dir]}/mysql-client.sh hops < #{Chef::Config[:file_cache_path]}/hops.sql
    EOF
    new_resource.updated_by_last_action(true)
    not_if "#{node[:ndb][:scripts_dir]}/mysql-client.sh hops -e \"show create table block_infos;\""
  end

end

end
