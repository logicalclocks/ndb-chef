action :install_distributed_privileges do
  # load the users using distributed privileges
  # http://dev.mysql.com/doc/refman/5.5/en/mysql-cluster-privilege-distribution.html
  new_resource.updated_by_last_action(false)
  if node['ndb']['enabled'] == "true"
  
    ndb_waiter "wait_mysql_started" do
       action :wait_until_cluster_ready
    end
  
    ndb_mysql_basic "mysqld_start_hop_install" do
      wait_time 10
      action :wait_until_started
    end
  
    distusers = "#{node['mysql']['version_dir']}/share/ndb_dist_priv.sql"
    bash 'create_distributed_privileges' do
      user node['ndb']['user']
      code <<-EOF
        #{node['ndb']['scripts_dir']}/mysql-client.sh < #{distusers}
        # Test that it works
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e "CALL mysql.mysql_cluster_move_privileges();" 
        echo "Verifying successful conversion of tables.."
        #{node['ndb']['scripts_dir']}/mysql-client.sh -e "SELECT CONCAT('Conversion ', IF(mysql.mysql_cluster_privileges_are_distributed(), 'succeeded', 'failed'), '.') AS Result;" | grep "Conversion succeeded" 
      EOF
      new_resource.updated_by_last_action(true)
      not_if "#{node['ndb']['scripts_dir']}/mysql-client.sh -e \"SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME LIKE 'mysql_cluster%'\"  | grep mysql_cluster", :user => "#{node['ndb']['user']}"
    end

  end
end
