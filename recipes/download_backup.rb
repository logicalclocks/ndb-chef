primary_mgm = node['ndb']['backup']['private_ips'][0]
backup_tarball = node['ndb']['restore']['tarball']
basename = File.basename(node['ndb']['restore']['tarball'], ".tar.gz")

bash 'copy-backup-from-primary' do
    user node['ndb']['user']
    group node['ndb']['group']
    code <<-EOF
        set -e
        pushd #{node['ndb']['local_backup_dir']}
        rm -f #{backup_tarball}
        rm -rf #{basename}
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null #{node['ndb']['user']}@#{primary_mgm}:#{node['ndb']['local_backup_dir']}/#{backup_tarball} .
        tar xzf #{backup_tarball}
        popd
    EOF
end
