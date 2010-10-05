require "bundler/capistrano"

set :environment, (ENV['target'] || 'staging')
set :application, 'datacatalog-api'
set :repository, "git://github.com/sunlightlabs/#{application}.git"
set :scm, :git
set :use_sudo, false
set :deploy_via, :remote_cache

# Documentation :runner and :admin_runner is here:
# http://weblog.jamisbuck.org/2008/6/13/capistrano-2-4-0
#
# These were set, but I don't see why they are needed, so I am commenting
# them out temporarily:
#
# set :runner, user
# set :admin_runner, runner

case environment
when 'production'
  set :domain, 'api.nationaldatacatalog.com'
  set :branch, 'production'
  set :user, "datcat"
  set :deploy_to, "/home/#{user}/www/#{application}"
when 'staging'
  set :domain, 'api.staging.nationaldatacatalog.com'
  set :branch, 'staging'
  set :user, "natdatcat"
  set :deploy_to, "/projects/#{user}/www/#{application}"
else
  raise "Invalid environment: #{environment}"
end

role :app, domain
role :web, domain

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :migrate do; end

  desc "Restart the server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join current_path, 'tmp', 'restart.txt'}"
  end

  desc "Get shared files into position"
  task :after_update_code, :roles => [:web, :app] do
    run "webgen -d #{release_path}/documentation"
    run "ln -nfs #{release_path}/documentation/out #{shared_path}/docs"

    %w(
      config.ru
      config/categories.yml
      config/config.yml
      config/organizations.yml
      config/users.yml
    ).each do |filename|
      run "ln -nfs #{shared_path}/#{filename} #{release_path}/#{filename}"
    end

    %w(
      tmp/pids
      public/system
      log
    ).each do |directory|
      run "rm #{File.join(release_path, directory)}"
    end
  end
end
