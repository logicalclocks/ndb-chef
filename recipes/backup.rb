## This recipe should run on mgm
env_vars = {}

unless node['ndb']['restore']['backup_id'].empty?
    env_vars['RONDB_BACKUP_ID'] = node['ndb']['restore']['backup_id']
end

unless node['ndb']['restore']['tarball'].empty?
    env_vars['RONDB_BACKUP_NAME'] = File.basename(node['ndb']['restore']['tarball'], ".tar.gz")
end

bash 'rondb_backup' do
    user node['ndb']['user']
    group node['ndb']['group']
    environment env_vars
    code <<-EOH
        set -e
        # Delete existing backup with the same id
        #{node['ndb']['scripts_dir']}/native_ndb_backup.sh -f
    EOH
end