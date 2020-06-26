actions :wait_until_cluster_ready, :backup_config

attribute :nowait_nodes, :kind_of => String, :default => ""

default_action :wait_until_cluster_ready
