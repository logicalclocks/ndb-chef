ndb_waiter "rr_wait_mysql_started" do
  action :wait_until_cluster_ready
end


include_recipe "ndb::ndbd"
