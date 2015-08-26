action :set do
 homedir = "#{new_resource.homedir}"
 contents = ::IO.read("#{homedir}/.ssh/id_rsa.pub")
 Chef::Log.info "Public key read is: #{contents}"
 node.default[:ndb][:mgmd][:public_key] = "#{contents}"

# This works for chef-solo - we are executing this recipe.rb file.
recipeName = "#{__FILE__}".gsub(/.*\//, "")
recipeName = "#{recipeName}".gsub(/\.rb/, "")
 
kagent_param "/tmp" do
  executing_cookbook "ndb"
  executing_recipe  "mgmd"
  cookbook "ndb"
  recipe "mgmd"
  param "public_key"
  value  node[:ndb][:mgmd][:public_key]
end

end


action :get do

homedir = "#{new_resource.homedir}"

Chef::Log.info "Mgm Server public key read is: #{node[:ndb][:mgmd][:public_key]}"

# Add the mgmd hosts' public key, so that they can start/stop the ndbd on this node
# using passwordless ssh.
# Dont append if the public key is already in the authorized_keys or is empty
bash "add_mgmd_public_key" do
 user node[:ndb][:user]
 group node[:ndb][:group]
 code <<-EOF
      mkdir #{homedir}/.ssh
      echo "#{node[:ndb][:mgmd][:public_key]}" >> #{homedir}/.ssh/authorized_keys
      touch #{homedir}/.ssh/.mgmd_key_authorized
  EOF
 not_if { ::File.exists?( "#{homedir}/.ssh/.mgmd_key_authorized" || "#{node[:ndb][:mgmd][:public_key]}".empty? ) }
end


end
