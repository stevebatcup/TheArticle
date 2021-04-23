# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

load File.expand_path("config/recipes/unicorn.rb")
load File.expand_path("config/recipes/bower.rb")
load File.expand_path("config/recipes/sidekiq.rb")
load File.expand_path("config/recipes/monit.rb")

set :application, "thearticle_rails"
set :repo_url, "git@github.com:stevebatcup/TheArticleRails.git"

set :deploy_to, "/var/www/thearticle/rails/"
set :use_sudo, false
set :keep_releases, 3
set :deploy_via, :remote_cache
set :pty, false

if fetch(:stage) == :production
  set :branch, "deploy"
  set :rails_env, "production"
elsif fetch(:stage) == :staging
  set :branch, "staging"
  set :rails_env, "staging"
end

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
append :linked_files, "config/nginx.conf", "config/database.yml", "config/master.key", "public/robots.txt", "public/firebase-messaging-sw.js"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", '.bundle', "bin"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# namespace :deploy do
#   desc 'Clear cache'
#   task :clear_cache do
#     on roles(:app) , in: :sequence, wait: 2 do
#       within release_path do
#         with rails_env: fetch(:rails_env) do
#           execute :sudo, 'rake', 'cache:clear'
#         end
#       end
#     end
#   end
#   after  :finishing, :clear_cache
# end

# before 'deploy:stop_unicorn', 'thinking_sphinx:rebuild'