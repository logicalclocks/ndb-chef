actions :systemd_reload, :start_if_not_running, :start_if_not_running_systemd, :flex

attribute :name, :kind_of => String, :name_attribute => true

default_action :start_if_not_running
