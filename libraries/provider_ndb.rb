# require 'chef/provider'

# class Chef
#   class Provider
#     class Ndb < Chef::Provider

#       def load_current_resource
#         @current_resource = Chef::Resource::Ark.new(@new_resource.name)
#       end

#       def action_download
#         unless new_resource.url =~ /^(http|ftp).*$/
#           new_resource.url = set_apache_url(url)
#         end
#         unless unpacked? new_resource.path
#           f = Chef::Resource::RemoteFile.new(new_resource.release_file, run_context)
#           f.source new_resource.url
#           if new_resource.checksum
#             f.checksum new_resource.checksum
#           end
#           f.run_action(:create)
#         end
#       end

#       def action_dump
#         set_dump_paths
#         action_download
#         action_dump_contents
#         action_set_owner new_resource.path
#       end

#       def action_install
#         set_paths
#         action_download
#         action_unpack
#         action_set_owner new_resource.path
#         action_install_binaries
#         action_link_paths
#       end

#       def action_link_paths
#         l = Chef::Resource::Link.new(new_resource.home_dir, run_context)
#         l.to new_resource.path
#         l.run_action(:create)
#       end

#       def action_dump_contents
#         full_path = ::File.join(new_resource.path, new_resource.creates)
#         chef_mkdir_p new_resource.path
#         cmd = expand_cmd
#         unless unpacked? full_path
#           eval("#{cmd}_dump") 
#           new_resource.updated_by_last_action(true)
#         end
#       end

#       def action_unpack
#         chef_mkdir_p new_resource.path
#         cmd = expand_cmd
#         unless unpacked? new_resource.path
#           eval(cmd)
#           new_resource.updated_by_last_action(true)
#         end
#       end

#       def action_set_owner(path)
#         require 'fileutils'
#         FileUtils.chown_R new_resource.owner, new_resource.group, path
#         FileUtils.chmod_R new_resource.mode, path
#       end

#       def action_install_binaries
#         unless new_resource.has_binaries.empty?
#           new_resource.has_binaries.each do |bin|
#             file_name = ::File.join(new_resource.prefix_bin, ::File.basename(bin))
#             l = Chef::Resource::Link.new(file_name, run_context)
#             l.to ::File.join(new_resource.path, bin)
#             l.run_action(:create)
#           end
#         end
#         if new_resource.append_env_path
#           append_to_env_path
#         end
#       end

#       private

#       def unpacked?(path)
#         if new_resource.creates
#           full_path = ::File.join(new_resource.path, new_resource.creates)
#         else
#           full_path = path
#         end
#         if ::File.directory? full_path
#           if ::File.stat(full_path).nlink == 2
#             false
#           else
#             true
#           end
#         elsif ::File.exists? full_path
#           true
#         else
#           false
#         end
#       end

#       def expand_cmd
#         case parse_file_extension
#         when /tar.gz|tgz/  then "tar_xzf"
#         when /tar.bz2|tbz/ then "tar_xjf"
#         when /zip|war|jar/ then "unzip"
#         else raise "Don't know how to expand #{new_resource.url}"
#         end
#       end

#       def set_paths
#         release_ext = parse_file_extension
#         prefix_bin  = new_resource.prefix_bin.nil? ? new_resource.run_context.node['ark']['prefix_bin'] : new_resource.prefix_bin
#         prefix_root = new_resource.prefix_root.nil? ? new_resource.run_context.node['ark']['prefix_root'] : new_resource.prefix_root
#         if new_resource.prefix_home.nil? 
#           default_home_dir = ::File.join(new_resource.run_context.node['ark']['prefix_home'], "#{new_resource.name}")
#         else
#           default_home_dir =  ::File.join(new_resource.prefix_home, "#{new_resource.name}")
#         end
#         # set effective paths
#         new_resource.prefix_bin = prefix_bin
#         new_resource.version ||= "1"  # initialize to one if nil
#         new_resource.path       = ::File.join(prefix_root, "#{new_resource.name}-#{new_resource.version}")
#         new_resource.home_dir ||= default_home_dir
#         Chef::Log.debug("path is #{new_resource.path}")
#         new_resource.release_file     = ::File.join(Chef::Config[:file_cache_path],  "#{new_resource.name}.#{release_ext}")
#       end

#       def set_dump_paths
#         release_ext = parse_file_extension
#         new_resource.release_file  = ::File.join(Chef::Config[:file_cache_path],  "#{new_resource.name}.#{release_ext}")
#       end

#       def parse_file_extension
#         if new_resource.extension.nil?
#           # purge any trailing redirect
#           url = new_resource.url.clone
#           url =~ /^https?:\/\/.*(.gz|bz2|bin|zip|jar|tgz|tbz)(\/.*\/)/
#           url.gsub!($2, '') unless $2.nil?
#           # remove tailing query string
#           release_basename = ::File.basename(url.gsub(/\?.*\z/, '')).gsub(/-bin\b/, '')
#           # (\?.*)? accounts for a trailing querystring
#           Chef::Log.debug("release_basename is #{release_basename}")
#           release_basename =~ %r{^(.+?)\.(tar\.gz|tar\.bz2|zip|war|jar|tgz|tbz)(\?.*)?}
#           Chef::Log.debug("file_extension is #{$2}")
#           new_resource.extension = $2
#         end
#         new_resource.extension
#       end

#       def set_apache_url(url_ref)
#         raise "Missing required resource attribute url" unless url_ref
#         url_ref.gsub!(/:name:/,          name.to_s)
#         url_ref.gsub!(/:version:/,       version.to_s)
#         url_ref.gsub!(/:apache_mirror:/, node['install_from']['apache_mirror'])
#         url_ref
#       end


#       def unzip
#         FileUtils.mkdir_p new_resource.path
#         if new_resource.strip_leading_dir
#           require 'tmpdir'
#           tmpdir = Dir.mktmpdir
#           cmd = Chef::ShellOut.new("unzip  -q -u -o '#{new_resource.release_file}' -d '#{tmpdir}'")
#           cmd.run_command
#           cmd.error!
#           subdirectory_children = Dir.glob("#{tmpdir}/**")
#           if subdirectory_children.length == 1
#             subdir = subdirectory_children[0]
#             subdirectory_children = Dir.glob("#{subdir}/**")
#           end
#           FileUtils.mv subdirectory_children, new_resource.path
#           FileUtils.rm_rf tmpdir
#         else
#           cmd = Chef::ShellOut.new("unzip  -q -u -o #{new_resource.release_file} -d #{new_resource.path}")
#           cmd.run_command
#           cmd.error!
#         end
#       end

#       def unzip_dump
#         cmd = Chef::ShellOut.new(
#                                  %Q{unzip  -j -q -u -o '#{new_resource.release_file}' -d '#{new_resource.path}'}
#                                  )
#         cmd.run_command
#         cmd.error!
#       end


#       def tar_xjf
#         untar_cmd("xjf")
#       end

#       def tar_xzf
#         untar_cmd("xzf")
#       end

#       def untar_cmd(sub_cmd)
#         if new_resource.strip_leading_dir
#           strip_argument = "--strip-components=1"
#         else
#           strip_argument = ""
#         end

#         b = Chef::Resource::Script::Bash.new(new_resource.name, run_context)
#         cmd = %Q{#{tar_cmd} -#{sub_cmd} #{new_resource.release_file} #{strip_argument} -C #{new_resource.path} }
#         b.flags "-x"
#         b.code <<-EOH
#           tar -#{sub_cmd} #{new_resource.release_file} #{strip_argument} -C #{new_resource.path}
#           EOH
#         b.run_action(:run)
#       end

#       def chef_mkdir_p(dir)
#         d = Chef::Resource::Directory.new(dir, run_context)
#         d.mode '0755'
#         d.recursive true
#         d.run_action(:create)
#       end

#       def append_to_env_path
#         if platform?("freebsd")
#           if new_resource.has_binaries.empty?
#             Chef::Log.warn "#{new_resource} specifies append_env_path but that is unimplemented on FreeBSD; " +
#               "consider using has_binaries"
#           else
#             Chef::Log.info "#{new_resource} specifies both has_binaries and append_env_path; " +
#               "the latter is a noop on FreeBSD."
#           end
#           return
#         end

#         new_path = ::File.join(new_resource.path, 'bin')
#         Chef::Log.debug("new_path is #{new_path}")
#         path = "/etc/profile.d/#{new_resource.name}.sh"
#         f = Chef::Resource::File.new(path, run_context)
#         f.content <<-EOF
#         export PATH=$PATH:#{new_path}
#         EOF
#         f.mode 0755
#         f.owner 'root'
#         f.group 'root'
#         f.run_action(:create)

#         bin_path = ::File.join(new_resource.path, 'bin')
#         if ENV['PATH'].scan(bin_path).empty?
#           ENV['PATH'] = ENV['PATH'] + ':' + bin_path
#         end
#         Chef::Log.debug("PATH after setting_path  is #{ENV['PATH']}")
#       end
#     end
#   end
# end
