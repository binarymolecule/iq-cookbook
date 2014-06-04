group "aws"

user "aws" do
  gid "aws"
end

bash "use automatic package source" do
  cwd "/etc/apt"
  code <<-EOT
    mv sources.list sources.list.us
    cat sources.list.us | sed 's/us.archive/archive/g' > sources.list
  EOT
  
  not_if do
    File.exists?("/etc/apt/sources.list.us")
  end
end

package "atool"

directory "#{node[:opsworks_agent][:current_dir]}/bin" do
  recursive true
end

file "#{node[:opsworks_agent][:current_dir]}/bin/extract" do
  mode '0755'
  content <<-EOT
    #!/bin/bash
    aunpack $1 -X $1.d
  EOT
end
