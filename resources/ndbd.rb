actions :init, :start, :stop, :restart

attribute :mgm_server, :kind_of => String, :name_attribute => true
attribute :node_id, :kind_of => Integer


def initialize( *args )
  super
end

default_action :restart
