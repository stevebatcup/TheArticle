require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post   'wp-connector/:model',     to: 'wp_connector#model_save'
	delete 'wp-connector/:model/:id', to: 'wp_connector#model_delete'
	mount Sidekiq::Web, at: '/sidekiq'
end
