namespace :deploy do
	task :stop_unicorn do
    on roles(:web) do
    	within release_path do
				execute "sudo systemctl stop unicorn"
			end
		end
  end
	task :regenerate_bins do
    on roles(:web) do
      within release_path do
	      execute :bundle, 'binstubs bundler --force'
	      execute :bundle, 'binstubs unicorn'
	    end
    end
  end
	task :start_unicorn do
    on roles(:web) do
    	within release_path do
				execute "sudo systemctl start unicorn"
			end
		end
  end
  task :fix_cache_permissions do
    on roles(:web) do
    	within release_path do
				execute *%w[ sudo chmod -R 777 /var/www/thearticle/rails/current/tmp/cache ]
			end
		end
  end
	before  :finishing, :regenerate_bins
	after :regenerate_bins, :stop_unicorn
	after  :stop_unicorn, :start_unicorn
	after  :start_unicorn, :fix_cache_permissions
end