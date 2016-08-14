action :install_grants do

ndb_waiter "wait_ndb_started" do
  action :wait_until_cluster_ready
  only_if { node.ndb.enabled == "true" }
end

ndb_mysql_basic "mysqld_start_grants" do
  wait_time 20
  remove_mycnf 1
  action :wait_until_started
end


grants_path = "#{Chef::Config.file_cache_path}/grants.sql"

exec= node.ndb.scripts_dir + "/mysql-client.sh"
bash 'run_grants' do
    user node.ndb.user
    code <<-EOF
     set -e
     export MYSQL_HOME=#{node.ndb.root_dir}
#     if [ $? != 0 ] ; then
#        exit 1
#     fi
     #{exec} -e "source #{grants_path}"
    EOF
    new_resource.updated_by_last_action(true)
    not_if "#{node.mysql.base_dir}/bin/mysql -u root --skip-password -S #{node.ndb.mysql_socket} -e \"SELECT user FROM mysql.user WHERE user=\"#{node.mysql.user}\"\"", :user => "#{node.ndb.user}"
#    not_if "#{node.mysql.base_dir}/bin/mysql -u root #{node.mysql.root.password.empty? ? '--skip-password' : '-p' }#{node.mysql.root.password} -S #{node.ndb.mysql_socket} -e \"SELECT user FROM mysql.user WHERE user=\"#{node.mysql.user}\""
#    not_if "#{node.mysql.base_dir}/bin/mysql -u #{node.mysql.user} -p#{node.mysql.password} -h localhost -e \"SELECT user FROM mysql.user WHERE host LIKE '\%';\""
  end
end

action :wait_until_started do

# mysql_install_db makes a copy of the my.cnf file in /etc/mysql. Remove it.
# FC021 for the next line's new_resource.name attribute
bash "remove_mycnf_#{new_resource.name}" do
    user "root"
    code <<-EOF
      rm -f /etc/mysql/my.cnf  
    EOF
    only_if { new_resource.remove_mycnf == 1 }
end

bash 'wait_mysqld_started' do
    user "root"
    code <<-EOF
    set -e || set -o pipefail
    service mysqld restart
    sleep 5
    if [ `#{node.mysql.base_dir}/bin/mysqladmin -u root -S #{node.ndb.mysql_socket} status` -ne 0 ] ; then
     wait=new_resource.wait_time
     timeout=0
     while [ $timeout -lt $wait ] ; do
         echo -n "."
         sleep 1
         if [ `#{node.mysql.base_dir}/bin/mysqladmin -u root -S #{node.ndb.mysql_socket} status` -eq 0 ] ; then
           timeout=new_resource.wait_time
         fi
         timeout=`expr $timeout + 1`
     done
      # If it did't work, try starting it again...
        if [ `#{node.mysql.base_dir}/bin/mysqladmin -u root -S #{node.ndb.mysql_socket} status` -ne 0 ] ; then
          service mysqld start
          sleep new_resource.wait_time
        fi
    fi

    # The mysqld may really not have started...
    if [ `#{node.mysql.base_dir}/bin/mysqladmin -u root -S #{node.ndb.mysql_socket} status` -ne 0 ] ; then
       echo "Something went badly wrong. Couldn't start mysqld. Trying to reinstall. Backing up to #{node.ndb.base_dir}/backup_mysql/"
       mkdir -p #{node.ndb.base_dir}/backup_mysql
       mv #{node.ndb.mysql_server_dir}* #{node.ndb.base_dir}/backup_mysql/

       export MYSQL_HOME=#{node.ndb.root_dir}
       cd #{node.mysql.base_dir}
       su #{node.ndb.user} -c "./bin/mysqld --defaults-file=#{node.ndb.root_dir}/my.cnf --initialize-insecure --explicit_defaults_for_timestamp"

       service mysqld start
       sleep new_resource.wait_time
    fi

    if [ `#{node.mysql.base_dir}/bin/mysqladmin -u root -S #{node.ndb.mysql_socket} status` -ne 0 ] ; then
         exit 1
    fi
    EOF
    not_if "#{node.mysql.base_dir}/bin/mysqladmin -u root -S #{node.ndb.mysql_socket} status", :user => "#{node.ndb.user}"
  end

  Chef::Log.info "MySQL Server has started."
  new_resource.updated_by_last_action(false)
end
