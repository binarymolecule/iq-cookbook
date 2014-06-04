#
# Cookbook Name:: iq
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

# include_recipe 'iq::credentials'
include_recipe 'deploy'
include_recipe "mod_php5_apache2"
include_recipe "mod_php5_apache2::php"

node[:deploy].each do |application, deploy|
  unless application == "iq" and deploy[:application_type] == "other"
    Chef::Log.debug("Skipping application #{application} as it is not an iq app")
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
  
  link "/srv/www/iq/vhosts" do
    to "#{deploy[:current_path]}/vhosts"
  end
  
  link "/srv/www/iq/production" do
    to "#{deploy[:current_path]}/project"
  end
  
  link "/srv/www/iq/staging" do
    to "#{deploy[:current_path]}/project"
  end
end
