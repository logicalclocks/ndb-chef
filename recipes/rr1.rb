
# First ndbmtd to start is only waiting on ndb_mgmd, so shorten wait-start timeout

wait_ndbd=node['ndb']['wait_startup']

node.override['ndb']['wait_startup'] = 30
ndb_waiter "rr_wait_mysql_started" do
  action :wait_until_cluster_ready
end
node.override['ndb']['wait_startup'] = wait_ndbd

include_recipe "ndb::ndbd"
