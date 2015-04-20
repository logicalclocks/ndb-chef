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
