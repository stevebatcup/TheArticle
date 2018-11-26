require 'sidekiq/web'

Rails.application.routes.draw do
  root 'home#index'
  get 'cookie-acceptance', 					to: 'cookie_acceptance#new'

  get 'exchanges',				 					to: 'exchanges#index'
  get 'exchange/:slug',				 			to: 'exchanges#show', as: :exchange

  get 'contributors',				 				to: 'contributors#index'
  get 'contributor/:slug',				 	to: 'contributors#show', as: :contributor

  post   'wp-connector/:model',     to: 'wp_connector#model_save'
	delete 'wp-connector/:model/:id', to: 'wp_connector#model_delete'

	mount Sidekiq::Web, at: '/sidekiq'

  get "*slug", to: "articles#show", as: :article
end
