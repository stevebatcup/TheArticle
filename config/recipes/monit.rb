namespace :monit do
  %w[start stop restart syntax reload].each do |command|
    desc "Run Monit #{command} script"
    task command do
    	on roles(:app) do
	      execute "sudo service monit #{command}"
	    end
    end
  end

  desc "Setup all Monit configuration"
  task :setup do
    invoke 'monit:syntax'
    invoke 'monit:reload'
  end
  after "deploy:updated", "monit:setup"
end