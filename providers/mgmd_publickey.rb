action :set do
 homedir = "#{new_resource.homedir}"
 contents = ::IO.read("#{homedir}/.ssh/id_rsa.pub")
 Chef::Log.info "Public key read is: #{contents}"
 node.default[:ndb][:mgmd][:public_key] = "#{contents}"

# This works for chef-solo - we are executing this recipe.rb file.
 recipeName = File.basename("#{__FILE__}")
 recipeName = File.basename("#{recipeName}", ".rb")
 
kagent_param "/tmp" do
  executing_cookbook "#{cookbook_name}"
  #  executing_recipe "#{recipe_name}"
  executing_recipe  "#{recipeName}"
  cookbook "ndb"
  recipe "mgmd"
  param "public_key"
  value  node[:ndb][:mgmd][:public_key]
end

end
