libpath = File.expand_path '../../libraries', __FILE__
require File.join(libpath, 'inifile')

hop_dir = File.dirname(node[:hop][:services])

directory hop_dir do
  owner node[:ndb][:user]
  group node[:ndb][:user]
  mode "755"
  action :create
  recursive true
end

file node[:hop][:services] do
  owner "root"
  group "root"
  mode 00755
  action :create_if_missing
end

