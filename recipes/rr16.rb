
# First ndbmtd to start is only waiting on ndb_mgmd, so shorten wait-start timeout

ndb_waiter "rr_wait_mysql_started" do
  nowait_nodes node['ndb']['new_node_ids']
  action :wait_until_cluster_ready
end

include_recipe "ndb::ndbd"
