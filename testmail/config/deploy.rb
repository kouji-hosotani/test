# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'tuna'
set :repo_url, 'git@github.com:mediba-system/tuna.git'
set :branch,  'master'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/html/tuna'

# Default value for :scm is :git
set :scm, :git

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/mongoid.yml config/secrets.yml config/aws_credential.yml config/aws_info_for_task.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
#set :default_env, {
#  rbenv_path: "/usr/local/rbenv",
#  path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
#}

set :rbenv_type, :user
set :rbenv_ruby, '2.2.3'
set :rbenv_path, "/usr/local/rbenv"
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :mkdir, '-p', release_path.join('tmp')
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Upload yml'
  task :upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute "mkdir -p #{shared_path}/config"
      end
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
      upload!('config/mongoid.yml', "#{shared_path}/config/mongoid.yml")
      upload!('config/secrets.yml', "#{shared_path}/config/secrets.yml")
    end
  end

  after :publishing, :restart
  after :restart, :clear_cache do
    #on roles(:web), in: :groups, limit: 3, wait: 10 do
    #  # Here we can do anything such as:
    #  within release_path do
    #    execute :rmdir, '-rf', release_path.join('tmp/cache')
    #  end
    #end
  end

  before :starting, 'deploy:upload'
  after :finishing, 'deploy:cleanup'

  namespace :assets do
    before :backup_manifest, 'deploy:assets:create_manifest_json'
    task :create_manifest_json do
      on roles :web do
        within release_path do
          execute :mkdir, release_path.join('assets_manifest_backup')
        end
      end
    end
  end
end
