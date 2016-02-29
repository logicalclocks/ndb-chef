
ark "dbt2" do
  url node.ndb.dbt2_binaries
  home_dir node.ndb.root_dir
  append_env_path true
  action :install
end

