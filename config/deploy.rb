set :application, 'hugotunius.se'
set :repository,  '_site'
set :scm, :git
set :repo_url, 'git@hugotunius.se:hugotunius.se.git'
set :deploy_via, :remote_cache

set :user, "deployer"
set :use_sudo, false
set :deploy_to, "/var/www/hugotunius"
set :ssh_options, { user: "deployer", forward_agent: true, auth_methods: %w(publickey password) }

namespace :deploy do

end