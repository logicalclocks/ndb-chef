#
#
# This test will create a databsae 'hops', insert create a table in hops,
# add a row to the table. Then make a backup of that database.
# Then shutdown the cluster, do an initial restart (that wipes the cluster),
# then restore the backup. The db/table/row should be back in the restored table.
#

bash "backup_restore_test" do
    user node['ndb']['user']
    code <<-EOF
set -e
cd #{node['ndb']['scripts_dir']}
./mgm-client.sh -e show
./mysql-client.sh -e "create database if not exists hops"
./mysql-client.sh hops -e "create table t1 (id int) "
./mysql-client.sh hops -e "insert into t1 values (1)"
./mysql-client.sh hops -e "select * from t1" | grep '1'
./backup-start.sh
./cluster-shutdown.sh
./cluster-init.sh -f
./backup-restore.sh 1
./mysql-server-start.sh --skip-grant-tables
./mysql-client.sh hops -e "select * from t1" | grep '1'
EOF
not_if "#{node['ndb']['scripts_dir']}/mysql-client.sh hops -e 'show tables' | grep t1"
end
