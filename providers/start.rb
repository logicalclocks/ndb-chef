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


action :start_if_not_running_systemd do


  bash "start-if-not-running-#{new_resource.name}" do
    user "root"
    code <<-EOH
     set -e
     if [ `systemctl status #{new_resource.name}` -ne 0 ] ; then
         systemctl start #{new_resource.name}
     fi 
    EOH
  end

end

action :systemd_reload do


  bash "systemd-reload-#{new_resource.name}" do
    user "root"
    code <<-EOH
     set -e
     systemctl daemon-reload
    EOH
  end

end



action :flex do

  bash "flex-experiment" do
    user node.ndb.user
    code <<-EOH
        #{node.ndb.scripts_dir}/flexAsyncRun.sh
    EOH
  end
  
end
