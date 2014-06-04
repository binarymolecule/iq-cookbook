include_recipe 'deploy'
include_recipe "mod_php5_apache2"
include_recipe "mod_php5_apache2::php"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_auth_basic"
include_recipe "apache2::mod_env"
include_recipe "apache2::mod_expires"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"

node[:deploy].each do |application, deploy|
  unless application == "iq" and deploy[:application_type] == "other"
    Chef::Log.info("Skipping application #{application} as it is not an iq app: #{deploy}")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
  
  file "#{node[:apache][:dir]}/conf.d/#{application}" do
    content "Include #{deploy[:current_path]}/vhosts/sites/"
  end
  
  template "#{node[:apache][:dir]}/conf.d/sni" do
    source "sni.erb"
    mode 0660
    group deploy[:group]
    owner deploy[:owner]
  end
  
  link "/srv/www/iq/vhosts" do
    to "#{deploy[:current_path]}/vhosts"
  end
  
  link "/srv/www/iq/production" do
    to "#{deploy[:current_path]}/project"
  end
  
  link "/srv/www/iq/staging" do
    to "#{deploy[:current_path]}/project"
  end
  
  link "/var/log/apache2" do
    to "/var/log/httpd"
  end
end
