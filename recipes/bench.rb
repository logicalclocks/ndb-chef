benchmarks_dir = "#{node['ndb']['user-home']}/benchmarks"

directory benchmarks_dir do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  action :create
end

sysbench_single_dir = "#{benchmarks_dir}/sysbench_single"
directory sysbench_single_dir do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  action :create
end

mysqld_host = ""
mysqld_hosts = ""
number_of_mysqld = 0
if node['ndb'].attribute?('mysqld')
  number_of_mysqld = node['ndb']['mysqld']['private_ips'].length()
  mysqld_hosts = node['ndb']['mysqld']['private_ips'].join(';')
  mysqld_host = node['ndb']['mysqld']['private_ips'][0]
end

template "#{sysbench_single_dir}/autobench.conf" do
  source "autobench_sysbench.conf.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0750
  variables({
    :sysbench_instances => "1",
    :mysqld_hosts => mysqld_host,
  })
end

sysbench_multi_dir = "#{benchmarks_dir}/sysbench_multi"
directory sysbench_multi_dir do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  action :create
end

template "#{sysbench_multi_dir}/autobench.conf" do
  source "autobench_sysbench.conf.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0750
  variables({
    :sysbench_instances => number_of_mysqld,
    :mysqld_hosts => mysqld_hosts,
  })
end

dbt2_single_dir = "#{benchmarks_dir}/dbt2_single"
directory dbt2_single_dir do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  action :create
end

template "#{dbt2_single_dir}/autobench.conf" do
  source "autobench_dbt2.conf.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0750
  variables({
    :mysqld_hosts => mysqld_host,
  })
end

cookbook_file "#{dbt2_single_dir}/dbt2_run_1.conf" do
  source "dbt2_run_1.conf.single"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0750
end

dbt2_multi_dir = "#{benchmarks_dir}/dbt2_multi"
directory dbt2_multi_dir do
  owner node['ndb']['user']
  group node['ndb']['group']
  mode "750"
  action :create
end

template "#{dbt2_multi_dir}/autobench.conf" do
  source "autobench_dbt2.conf.erb"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0750
  variables({
    :mysqld_hosts => mysqld_hosts,
  })
end

cookbook_file "#{dbt2_multi_dir}/dbt2_run_1.conf" do
  source "dbt2_run_1.conf.multi"
  owner node['ndb']['user']
  group node['ndb']['group']
  mode 0750
end
