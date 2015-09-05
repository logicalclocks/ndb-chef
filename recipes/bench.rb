bash "install_flexasync" do
    user "root"
    code <<-EOF
    cd #{node[:ndb][:scripts_dir]}
    wget http://snurran.sics.se/hops/flexAsync .
EOF
end



template "#{node[:ndb][:scripts_dir]}/flexAsync.sh" do
  source "flexAsync.sh.erb"
  owner node[:ndb][:user]
  group node[:ndb][:user]
  mode 0754
  variables({ :mgmd_ip => node[:ndb][:mgmd][:private_ips][0] })
end
