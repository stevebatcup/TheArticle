require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }
  root 'home#index'
  get 'cookie-acceptance',                     to: 'cookie_acceptance#new'
  get 'search',                                to: 'articles#index', as: :search
  get 'articles',                              to: 'articles#index', as: :articles
  get 'contact',                               to: 'contact#new'
  post 'contact',                              to: 'contact#create'
  get 'username-availability',                 to: 'username_availability#new'

  post 'register',                             to: 'register#create'
  get 'profile/new',                           to: 'profile_wizard#new', as: :profile_wizard
  post 'profile',                              to: 'profile_wizard#create', as: :save_profile_wizard
  get 'profile/:username',                     to: 'users#show', as: :profile

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
  get 'my-profile',                            to: 'users#show'
  get 'following',                             to: 'follows#index', mode: :following
  get 'followers',                             to: 'follows#index', mode: :followers
  get 'follow-suggestions',                    to: 'follows#index', mode: :suggestions
  get 'account-settings',                      to: 'account_settings#edit'

  PageRouter.load
	mount Sidekiq::Web, at: '/sidekiq'
  get "*slug", to: "articles#show", as: :article, constraints: lambda { |req|
    req.path.exclude? 'amazonaws.com'
  }
end
