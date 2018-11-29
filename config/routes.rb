require 'sidekiq/web'

Rails.application.routes.draw do
  root 'home#index'
  get 'cookie-acceptance',          to: 'cookie_acceptance#new'
  get 'contact',                    to: 'contact#new'
  post 'contact',                   to: 'contact#create'
  post 'register',                   to: 'register#create'

  get 'exchanges',				 					to: 'exchanges#index'
  get 'exchange/:slug',				 			to: 'exchanges#show', as: :exchange

  get 'sponsors',                   to: 'sponsors#index'
  get 'contributors',               to: 'contributors#index'
  get 'contributor/:slug',				 	to: 'contributors#show', as: :contributor

  post   'wp-connector/:model',     to: 'wp_connector#model_save'
	delete 'wp-connector/:model/:id', to: 'wp_connector#model_delete'
  post   'wp-connector/:model/:id/unpublish',  to: 'wp_connector#model_delete'

  PageRouter.load
  # ArticleRouter.load
	mount Sidekiq::Web, at: '/sidekiq'
  get "*slug", to: "articles#show", as: :article
end
