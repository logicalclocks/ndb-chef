
def find_mysql_id(ip)
  found_id = -1
  id = node.mysql.id
  for api in node.ndb.mysqld.private_ips
    if ip.eql? api
      Chef::Log.info "Found matching IP address in the list of nodes: #{api} . ID= #{id}"
      found_id = id
    end
    id += 1
  end 
if found_id == -1
   Chef::Log.fatal "Could not find matching IP address in list the mysql servers."
end

  return found_id
end

def find_memcached_id(ip)
  found_id = -1
  id = node.memcached.id
  for api in node.ndb.memcached.private_ips
    if ip.eql? api
      Chef::Log.info "Found matching IP address in the list of nodes: #{api} . ID= #{id}"
      found_id = id
    end
    id += 1
  end 
if found_id == -1
   Chef::Log.fatal "Could not find matching IP address in list the mysql servers."
end

  return found_id
end
