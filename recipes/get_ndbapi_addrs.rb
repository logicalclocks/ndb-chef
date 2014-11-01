def get_ndbapi_addrs()
  # Note, we do not remove duplicates from the ndbapi array, as duplicates
  # mean more than one ndbapi app may connect from this host, which is ok.

  a = Array.new

  # mysqld nodes are ndbapi clients
  if (node.attribute?(:ndb) && node[:ndb].attribute?(:mysqld) && node[:ndb][:mysqld].attribute?(:private_ips) && !node[:ndb][:mysqld][:private_ips].empty?)
     a.push(*node[:ndb][:mysqld][:private_ips])    
  end
  # memcached nodes are ndbapi clients
  if (node.attribute?(:ndb) && node[:ndb].attribute?(:memcached) && node[:ndb][:memcached].attribute?(:private_ips) && !node[:ndb][:memcached][:private_ips].empty?)
     a.push(*node[:ndb][:memcached][:private_ips])    
  end
  # clusterj nodes in hop::nn nodes are ndbapi clients
  if (node.attribute?(:hop) && node[:hop].attribute?(:nn) && node[:hop][:nn].attribute?(:private_ips) && !node[:hop][:nn][:private_ips].empty?)
    a.push(*node[:hop][:nn][:private_ips])    
  end

  Chef::Log.info "Ndapi Addrs untrimmed are: " + a.join(",")
  a.uniq
  Chef::Log.info "Ndapi Addrs trimmed are: " + a.join(",")

  node.normal[:ndb][:ndbapi][:addrs] = a
  return a
end


def generate_etc_hosts() 
  id = 1
  if (node.attribute?(:ndb) && node[:ndb].attribute?(:ndbd) && node[:ndb][:ndbd].attribute?(:private_ips) && !node[:ndb][:ndbd][:private_ips].empty?)
    for n in node[:ndb][:ndbd][:private_ips]
       generate_hosts("ndbd{id}", n)    
       id += 1
     end
  end

  id = node[:mgmd][:id]
  if (node.attribute?(:ndb) && node[:ndb].attribute?(:mgmd) && node[:ndb][:mgmd].attribute?(:private_ips) && !node[:ndb][:mgmmd][:private_ips].empty?)
    for n in node[:ndb][:mgmd][:private_ips]
       generate_hosts("mgmd{id}", n)    
       id += 1
     end
  end


  id = node[:mysql][:id]
  if (node.attribute?(:ndb) && node[:ndb].attribute?(:mysqld) && node[:ndb][:mysqld].attribute?(:private_ips) && !node[:ndb][:mysqld][:private_ips].empty?)
     for n in node[:ndb][:mysqld][:private_ips]
       generate_hosts("ndbapi{id}", my_ip)    
       id += 1
     end
  end

  # memcached nodes are ndbapi clients
  id = node[:memcached][:id]
  if (node.attribute?(:ndb) && node[:ndb].attribute?(:memcached) && node[:ndb][:memcached].attribute?(:private_ips) && !node[:ndb][:memcached][:private_ips].empty?)
     for n in node[:ndb][:memcached][:private_ips]
       generate_hosts("ndbapi{id}", my_ip)    
       id += 1
     end

  end

  # clusterj nodes in hop::nn nodes are ndbapi clients
  id = node[:nn][:id]
  if (node.attribute?(:hop) && node[:hop].attribute?(:nn) && node[:hop][:nn].attribute?(:private_ips) && !node[:hop][:nn][:private_ips].empty?)
     for n in node[:hop][:nn][:private_ips]
       generate_hosts("ndbapi{id}", my_ip)    
       id -= 1
     end
  end



end
# TODO - is there a bug here if >1 service (e.g., ndbd + mysqld) are installed on the
# same host? Both would have different hostIds, leading to fqdn having different values
# The order in which they are run would determine which one ends up as the /etc/hosts file.
def generate_hosts(hostId, my_ip) 
  # template "/etc/hosts" do
  #   source "hosts.erb"
  #   owner "root"
  #   group "root"
  #   mode 0644
  #   variables({
  #               :mgm_id => node[:mgm][:id],
  #               :mysql_id => node[:mysql][:id],
  #               :fqdn => hostId,
  #               :my_ip => my_ip
  #             })
  # end

hostsfile_entry "#{my_ip}" do
  hostname  "#{hostId}"
  unique    true
  action    :create
end

  ndb_hostname hostId do
  end
end
