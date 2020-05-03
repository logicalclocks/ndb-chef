# coding: utf-8


# Reference: https://dev.mysql.com/doc/refman/5.7/en/mysql-cluster-online-add-node-basics.html
# Step 1. Run a Karamel cluster defn with only the new ndb/ndbd/ips_ids (not the new worker sections) and do a rolling restart. This will update the config.ini
# Step 2. Run a cluster definition file where you add the new NDBDs as worker sections and you add this recipe to the head node (add_nodes.rb).

if node['ndb']['enabled'] == "true"
  ndb_mysql_ndb "create_nodegroup" do
    action :create_nodegroup
  end
end



# For all tables to be re-organized, run this:
# ALTER TABLE ... ALGORITHM=INPLACE, REORGANIZE PARTITION
# ALTER TABLE ... REORGANIZE PARTITION ALGORITHM=INPLACE reorganizes partitions but does not reclaim the space freed on the “old” nodes.
# You can do this by issuing, for each NDBCLUSTER table, an OPTIMIZE TABLE statement in the mysql client.
# This works for space used by variable-width columns of in-memory NDB tables.
# OPTIMIZE TABLE is not supported for fixed-width columns of in-memory tables; it is also not supported for Disk Data tables.

hops="hops-tables-2.8.2.10-SNAPSHOT.txt"

cookbook_file "#{Chef::Config['file_cache_path']}/#{hops}" do
  source hops 
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0700
end

hopsworks="hopsworks_tables-1.3.0.txt"

cookbook_file "#{Chef::Config['file_cache_path']}/#{hopsworks}" do
  source hopsworks
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0700
end

hops_tables = File.readlines(#{Chef::Config['file_cache_path']}/#{hops})
hopsworks_tables = File.readlines("#{Chef::Config['file_cache_path']}/#{hopsworks}")

for table in hops_tables
  ndb_mysql_ndb "reorganize_hops_table" do
    database "hops"
    table table
    action :reorganize_table
  end
end

for table in hopsworks_tables
  ndb_mysql_ndb "reorganize_hopsworks_table" do
    database "hopsworks"    
    table table
    action :reorganize_table
  end
end
