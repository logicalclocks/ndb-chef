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

tables = %w{ }
for table in tables

  ndb_mysql_ndb "reorganize_table" do
    table table
    action :optimize_table
  end

end
