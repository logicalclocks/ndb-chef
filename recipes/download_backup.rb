primary_mgm = node['ndb']['backup']['private_ips'][0]
backup_tarball = node['ndb']['restore']['tarball']

bash 'copy-backup-from-primary' do
    user node['ndb']['user']
    group node['ndb']['group']
    code <<-EOF
        set -e
        pushd #{node['ndb']['local_backup_dir']}
        scp #{node['ndb']['user']}@#{primary_mgm}:#{node['ndb']['local_backup_dir']}/#{backup_tarball} .
        tar xzf #{backup_tarball}
        popd
    EOF
end
