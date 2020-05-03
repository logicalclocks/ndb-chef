action :install_distributed_privileges do
  # load the users using distributed privileges
  # http://dev.mysql.com/doc/refman/5.5/en/mysql-cluster-privilege-distribution.html
  new_resource.updated_by_last_action(false)
  if node['ndb']['enabled'] == "true"
  
    ndb_waiter "wait_mysql_started" do
       nowait_nodes node['ndb']['new_node_ids']      
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


action :create_nodegroup do

  new_resource.updated_by_last_action(false)
  if node['ndb']['enabled'] == "true"
  
    ndb_waiter "wait_mysql_started" do
       nowait_nodes node['ndb']['new_node_ids']      
       action :wait_until_cluster_ready
    end
  
    ndb_mysql_basic "mysqld_start_hop_install" do
      wait_time 10
      action :wait_until_started
    end

    firstId="#{node['ndb']['new_node_ids']}"
    firstId = firstId.split(/,/).first
    # ./mgm-client.sh -e "show"
    # returns the list of NDBDs and what nodegroups they belong to.
    # Test if the first new_node_ids entry already belongs to a nodegroup.
    # If True, then do not create a NodeGroup.
    # Here is what we are matching against:
    #
    # Cluster Configuration
    # ---------------------
    #  [ndbd(NDB)]     4 node(s)
    #
    # id=3    @10.0.0.10  (mysql-5.7.25 ndb-7.6.9, Nodegroup: 1)
    # ^^^^                                       ^^^^^^^^^^^^^   
    
    bash 'create_nodegroup' do
      user node['ndb']['user']
      ignore_failure true
      code <<-EOF
        #{node['ndb']['scripts_dir']}/mgm-client.sh -e "CREATE NODEGROUP #{node['ndb']['new_node_ids']}"
      EOF
      new_resource.updated_by_last_action(true)
      not_if "#{node['ndb']['scripts_dir']}/mgm-client.sh -e \"show\"  | grep \"^id=#{firstId}\" | grep \", Nodegroup: \", :user => "#{node['ndb']['user']}"
    end

  end
end


action :optimize_table do
  if node['ndb']['enabled'] == "true"
    table = new_resource.table
    bash 'reorganize_partition' do
      user node['ndb']['user']
      code <<-EOF
        #{node['ndb']['scripts_dir']}/mysql-client.sh < "ALTER TABLE #{table} ALGORITHM=INPLACE, REORGANIZE PARTITION"
      EOF
      new_resource.updated_by_last_action(true)
    end
  end
end

