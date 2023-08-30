module NDB
    module Helpers
        # TODO(Fabio): this method was moved from a recipe. Check if the ID thing actually works.
        def find_service_id(service, base_id)
          found_id = -1
          my_ip = my_private_ip()
          id = base_id
        
          if node.attribute?(:ndb) && node['ndb'].attribute?(service) && node['ndb'][service].attribute?(:ips_ids) && !node['ndb'][service]['ips_ids'].empty?
            for srv in node['ndb'][service]['ips_ids']
              theNode = srv.split(":")
              if my_ip.eql? theNode[0]
                found_id = theNode[1]
                break
              end
            end
          else
            for api in node['ndb'][service]['private_ips']
              if my_ip.eql? api
                Chef::Log.info "Found matching IP address in the list of #{service} nodes: #{api} . ID= #{id}"
                found_id = id
              end
              id += 1
            end
          end
      
          if found_id == -1
             Chef::Log.fatal "Could not find matching IP address in list of #{service}."
          end
      
          return found_id
        end

        def rondb_restoring_backup
          !node['ndb']['restore']['backup_id'].empty? && !node['ndb']['restore']['tarball'].empty?
        end

        def mysql_server_id
          startId = node['ndb']['replication']['cluster-id'].to_i
          my_ip = my_private_ip()
          idx = node['ndb']['mysqld']['private_ips'].sort().index(my_ip)
          server_id = startId + idx
          return server_id
        end
    end
end

Chef::Recipe.send(:include, NDB::Helpers)
Chef::Resource.send(:include, NDB::Helpers)