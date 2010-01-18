# Use Git for deployment - git-specific options
default_run_options[:pty] = true
set :scm, "git"
set :repository,  "git@github.com:davetroy/honeycomb.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1

set :application, "honeycomb"
set :keep_releases, 3

role :app, "hive.beehivebaltimore.org"
role :daemons, "hive.beehivebaltimore.org"
role :db, "hive.beehivebaltimore.org", :primary=>true

set :use_sudo, false
set :user, application
set :deploy_to, "/home/#{application}"

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :db do
  task :create, :roles => :db do
    run "cd #{current_path}; rake RAILS_ENV=production db:create"
  end
  task :drop, :roles => :db do
    run "cd #{current_path}; rake RAILS_ENV=production db:drop"
  end
end
  

namespace :daemons do
  desc "Start Daemons"
  task :start, :roles => :daemons do
    run "#{deploy_to}/current/script/daemons start"
  end

  desc "Stop Daemons"
  task :stop, :roles => :daemons do
    run "#{deploy_to}/current/script/daemons stop"
		run "sleep 5 && killall -9 ruby"
  end
end

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/paypal.yml #{release_path}/config/paypal.yml" 
end
