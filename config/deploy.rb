#rbenv config
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.0.0-p353'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby jekyll}
set :rbenv_roles, :all # default value

set :default_env, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

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


namespace :deploy do
  [:start, :stop, :restart, :finalize_update].each do |t|
    desc "#{t} task is a no-op with jekyll"
    task t do ; end
  end

  desc 'Run jekyll to update site before uploading'
  task :update_jekyll do
    on roles(:app) do
      within release_path do
        with path: "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" do
          execute "rm -rf _site/*"
          execute :jekyll, "build"
        end
      end
    end
  end

  task :clean_jekyll do
    on roles(:app) do
      within release_path do
        execute "mv css _site"
        execute "rm Capfile _config.yml Gemfile* index.slim"
        execute "rm -rf config _drafts fonts img _includes _layouts _plugins _sass"
      end
    end
  end

  after :finishing, "deploy:update_jekyll"
  after "deploy:update_jekyll", "deploy:clean_jekyll"
end