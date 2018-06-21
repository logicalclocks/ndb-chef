
def find_mysql_id(ip)
  found_id = -1
  id = node['mysql']['id']

  if node.attribute?(:ndb) && node['ndb'].attribute?(:mysqld) && node['ndb']['mysqld'].attribute?(:ips_ids) && !node['ndb']['mysqld']['ips_ids'].empty?
    for mysql in node['ndb']['mysqld']['ips_ids']
      theNode = mysql.split(":")
      if my_ip.eql? theNode[0]
        found_id = theNode[1]
        break
      end
    end
  else
    for api in node['ndb']['mysqld']['private_ips']
      if ip.eql? api
        Chef::Log.info "Found matching IP address in the list of nodes: #{api} . ID= #{id}"
        found_id = id
      end
      id += 1
    end
  end
if found_id == -1
   Chef::Log.fatal "Could not find matching IP address in list the mysql servers."
end

  return found_id
end

def find_memcached_id(ip)
  found_id = -1
  id = node['memcached']['id']
  for api in node['ndb']['memcached']['private_ips']
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
