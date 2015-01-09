action :start_if_not_running do
  bash "start-if-not-running-#{new_resource.name}" do
    user "root"
    code <<-EOH
     set -e
     if [ `service #{new_resource.name} status` -ne 0 ] ; then
         service #{new_resource.name}
     fi 
    EOH
  end

end
