case node["platform_family"]
when "debian"
    systemd_dir = "/lib/systemd/system"
when "rhel"
    systemd_dir = "/usr/lib/systemd/system"
end

template "#{systemd_dir}/rondb-heartbeater.service" do
    source "replication/rondb-heartbeater.service.erb"
    owner 'root'
    group 'root'
    mode 0744
end

template "#{systemd_dir}/rondb-monitor.service" do
    source "replication/rondb-monitor.service.erb"
    owner 'root'
    group 'root'
    mode 0744
end

