namespace :sidekiq do
  desc 'Restart sidekiq'
  task :restart do
    on roles(:web) do
      within release_path do
        # execute "sudo systemctl restart redis.service"
        execute "sudo systemctl restart sidekiq.service"
      end
    end
  end
end
before 'deploy:compile_assets', 'sidekiq:restart'