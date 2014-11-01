#require 'chef/resource'

# class Chef
#   class Resource
#     class Ndb < Chef::Resource

#       def initialize(name, run_context=nil)
#         super
#         @resource_name = :ndb
#         @allowed_actions.push(:install, :dump, :init)
#         @action = :install
#         @provider = Chef::Provider::Ndb
#       end

#       attr_accessor :path, :release_file, :prefix_bin, :prefix_root, :home_dir, :version

#       attribute :owner, :kind_of => String, :default => 'root'
#       attribute :group, :kind_of => [String, Fixnum], :default => 0
#       attribute :url, :kind_of => String, :required => true
#       attribute :path, :kind_of => String, :default => nil
#       attribute :full_path, :kind_of => String, :default => nil
#       attribute :append_env_path, :kind_of => [TrueClass, FalseClass], :default => false
#       attribute :has_binaries, :kind_of => Array, :default => []
#       attribute :mode, :kind_of => Fixnum, :default => 0755
#       attribute :prefix_root, :kind_of => String, :default => nil
#       attribute :prefix_home, :kind_of => String, :default => nil
#       attribute :prefix_bin, :kind_of => String, :default => nil
#       attribute :version, :kind_of => String, :default => nil
#       attribute :home_dir, :kind_of => String, :default => nil
#       attribute :environment, :kind_of => Hash, :default => {}
#       attribute :home_dir, :kind_of => String, :default => nil
#       attribute :extension, :kind_of => String

#     end
#   end
# end
