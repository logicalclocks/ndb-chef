action :set_hostname do

    bash "update_etc_hosts" do
      user "root"
      code <<-EOF
      echo "#{new_resource.fqdn}" > /etc/hostname
      EOF
    end


  case node[:platform_family]
  when "debian"

    bash "set_hostname" do
      user "root"
      code <<-EOF
      sudo hostname #{new_resource.fqdn}
      EOF
    end

  when "rhel"

    bash "set_hostname" do
      user "root"
      code <<-EOF
      echo "HOSTNAME=#{new_resource.fqdn}" > /etc/sysconfig/network
      hostname #{new_resource.fqdn}
      hostname       
      EOF
    end
  end

  new_resource.updated_by_last_action(true)
end
