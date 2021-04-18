actions :install_grants, :wait_until_started

attribute :wait_time, :kind_of => Integer, :default => 20
attribute :remove_mycnf, :kind_of => Integer, :default => 0
attribute :benchmark, :kind_of => String, :default => "false"

default_action :install_grants
