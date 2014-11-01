actions :set_hostname

attribute :fqdn, :kind_of => String, :name_attribute => true, :required => true

default_action :set_hostname
