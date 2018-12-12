require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  get 'cookie-acceptance',                     to: 'cookie_acceptance#new'
  get 'search',                                to: 'articles#index', as: :search
  get 'articles',                              to: 'articles#index', as: :articles
  get 'contact',                               to: 'contact#new'
  post 'contact',                              to: 'contact#create'

  post 'register',                             to: 'register#create'
  get 'new_profile',                           to: 'profile_wizard#new', as: :profile_wizard
  post 'new_profile',                          to: 'profile_wizard#create'

  get 'exchanges',				 					           to: 'exchanges#index'
  get 'exchange/:slug',				 			           to: 'exchanges#show', as: :exchange

  get 'contributors',                          to: 'contributors#index'
  get 'contributor/:slug',                     to: 'contributors#show', as: :contributor
  get 'sponsors',                              to: 'sponsors#index'
  get 'sponsor',                               to: 'sponsors#show', as: :sponsor

  post   'wp-connector/:model',                to: 'wp_connector#model_save'
	delete 'wp-connector/:model/:id',            to: 'wp_connector#model_delete'
  post   'wp-connector/:model/:id/unpublish',  to: 'wp_connector#model_delete'

  get 'front-page',                            to: 'front_page#index', as: :front_page

  PageRouter.load
	mount Sidekiq::Web, at: '/sidekiq'
  get "*slug", to: "articles#show", as: :article, constraints: lambda { |req|
    req.path.exclude? 'amazonaws.com'
  }
end
