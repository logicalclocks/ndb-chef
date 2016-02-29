def get_ndbapi_addrs()
  # Note, we do not remove duplicates from the ndbapi array, as duplicates
  # mean more than one ndbapi app may connect from this host, which is ok.

  a = Array.new

  # mysqld nodes are ndbapi clients
  if (node.attribute?(:ndb) && node.ndb.attribute?(:mysqld) && node.ndb.mysqld.attribute?(:private_ips) && !node.ndb.mysqld.private_ips.empty?)
     a.push(*node.ndb.mysqld.private_ips)    
  end
  # memcached nodes are ndbapi clients
  if (node.attribute?(:ndb) && node.ndb.attribute?(:memcached) && node.ndb.memcached.attribute?(:private_ips) && !node.ndb.memcached.private_ips.empty?)
     a.push(*node.ndb.memcached.private_ips)    
  end
  # clusterj nodes in hop::nn nodes are ndbapi clients
  if (node.attribute?(:hop) && node.hop.attribute?(:nn) && node.hop.nn.attribute?(:private_ips) && !node.hop.nn.private_ips.empty?)
    a.push(*node.hop.nn.private_ips)    
  end

  Chef::Log.info "Ndapi Addrs untrimmed are: " + a.join(",")
  a.uniq
  Chef::Log.info "Ndapi Addrs trimmed are: " + a.join(",")

  node.normal.ndb.ndbapi.addrs = a
  return a
end

