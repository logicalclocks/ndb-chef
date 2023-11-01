require 'open3'

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

        def mysql_server_id(node_ip, clusterId)
          startId = clusterId.to_i
          octets = node_ip.split(".")
          server_id = "#{startId}#{octets[2]}#{octets[3]}"
          return server_id
        end

        def get_mysql_server_id()
          o, s = Open3.capture2("grep -r \"server-id\" #{node['ndb']['root_dir']}/my.cnf")
          if !s.success?
            raise "Could not read server-id from #{node['ndb']['root_dir']}/my.cnf"
          end
          server_id = o.split("=")[1].strip().to_s()
          Chef::Log.info "Read server-id #{server_id}"
          return server_id
        end

        def generate_rdrs_mgmd_conf(conn_str)
          conn_str_split = conn_str.split(/:/, 2)
          return "[{\"IP\": \"#{conn_str_split[0]}\", \"Port\": #{conn_str_split[1]} }]"
        end
    end
end

Chef::Recipe.send(:include, NDB::Helpers)
Chef::Resource.send(:include, NDB::Helpers)