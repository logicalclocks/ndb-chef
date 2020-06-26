# Run DB benchmarks 

remote_file "#{node['ndb']['scripts_dir']}/flexAsync" do
  source "http://snurran.sics.se/hops/flexAsync"  
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0755
  action :create
end

template "#{node['ndb']['scripts_dir']}/flexAsync.sh" do
  source "flexAsync.sh.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0754
  variables({ :mgmd_ip => node['ndb']['mgmd']['private_ips'][0] })
end


remote_file "#{Chef::Config['file_cache_path']}/dbt2.tar.gz" do
  source node['ndb']['dbt2_binaries']  
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0755  
  action :create
end

bash "unpack_bt2" do
    user "root"
    code <<-EOF
cd #{Chef::Config['file_cache_path']} 
tar -xzf dbt2.tar.gz -C #{node['ndb']['scripts_dir']}
EOF
end
