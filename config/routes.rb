require 'sidekiq/web'

Rails.application.routes.draw do
  root 'home#index'
  get 'cookie-acceptance', 					to: 'cookie_acceptance#new'

  post   'wp-connector/:model',     to: 'wp_connector#model_save'
	delete 'wp-connector/:model/:id', to: 'wp_connector#model_delete'
	mount Sidekiq::Web, at: '/sidekiq'
end
