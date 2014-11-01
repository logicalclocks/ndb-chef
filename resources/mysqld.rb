actions :start, :stop, :restart

attribute :mgm_server, :kind_of => String, :name_attribute => true
attribute :restype, :kind_of => String, :required => true
attribute :enabled, :equal_to => [true, false, 'true', 'false'], :default => nil

def initialize( *args )
  super
end

default_action :restart
