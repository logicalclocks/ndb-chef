require 'open3'
require 'time'

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

        def is_tls_already_configured()
          _, s = Open3.capture2("grep -e \"^[[:space:]]*ssl-cert\" #{node['ndb']['root_dir']}/my.cnf")
          return s.success?
        end

        def mysqld_configuration(tls = false)
          conf = Hash.new
          conf[:mysql_id] = find_service_id("mysqld", node['mysql']['id'])
          conf[:timezone] = Time.now.strftime("%:z")
          conf[:server_id] = mysql_server_id(my_private_ip(), node['ndb']['replication']['cluster-id'])
          conf[:am_i_primary] = node['ndb']['replication']['role'].casecmp?('primary')
          if conda_helpers.is_upgrade() && node['mysql']['safe-upgrade'].casecmp?("true")
            conf[:dist_upgrade_allowed] = 0
          else
            conf[:dist_upgrade_allowed] = 1
          end
          if tls
            conf[:mysql_tls] = true
            crypto_dir = x509_helper.get_crypto_dir(node['ndb']['user'])
            conf[:certificate] = "#{crypto_dir}/#{x509_helper.get_certificate_bundle_name(node['ndb']['user'])}"
            conf[:key] = "#{crypto_dir}/#{x509_helper.get_private_key_pkcs1_name(node['ndb']['user'])}"
            conf[:hops_ca] = "#{crypto_dir}/#{x509_helper.get_hops_ca_bundle_name()}"
          else
            conf[:mysql_tls] = false
          end

          return conf
        end
    end
end

Chef::Recipe.send(:include, NDB::Helpers)
Chef::Resource.send(:include, NDB::Helpers)