set :application, 'hugotunius.se'
set :repository,  '_site'
set :scm, :git
set :repo_url, 'git@hugotunius.se:hugotunius.se.git'
set :deploy_via, :remote_cache

set :user, "deployer"
set :group, "www-data"
set :use_sudo, false
set :deploy_to, "/var/www/hugotunius"
set :ssh_options, { user: "deployer", forward_agent: true, auth_methods: %w(publickey password) }

after 'deploy:finished', 'deploy:update_jekyll'

namespace :deploy do
  [:start, :stop, :restart, :finalize_update].each do |t|
    desc "#{t} task is a no-op with jekyll"
    task t do ; end
  end

  desc 'Run jekyll to update site before uploading'
  task :update_jekyll do
    %x(rm -rf _site/* && bundle && jekyll build)
    %x(shopt -s extglob dotglob && rm -rf !(_site))
  end
end