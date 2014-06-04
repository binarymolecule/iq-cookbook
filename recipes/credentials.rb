include_recipe 'deploy'
include_recipe "mod_php5_apache2"
include_recipe "mod_php5_apache2::php"

node[:deploy].each do |app_name, deploy|
  template "#{deploy[:deploy_to]}/current/wp-localconfig.php" do
    source "wp-localconfig.php.erb"
    mode 0660
    group deploy[:group]
    owner deploy[:owner]

    variables(
      :host =>     (deploy[:database][:host] rescue nil),
      :user =>     (deploy[:database][:username] rescue nil),
      :password => (deploy[:database][:password] rescue nil),
      :db =>       (deploy[:database][:database] rescue nil),
      :url =>      (deploy[:domains].first rescue nil),
      :storage =>  (deploy[])
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current")
    end
  end
end
