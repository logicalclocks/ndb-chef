service_name = "ndbmtd"

ndb_waiter "rr_wait_mysql_started" do
  action :wait_until_cluster_ready
end

service "#{service_name}" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true
  action :restart
end

