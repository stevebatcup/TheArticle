require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations", sessions: "sessions", passwords: "passwords" }
  root 'home#index'
  get 'cookie-acceptance',                     to: 'cookie_acceptance#new'
  get 'accept-testing-environment',            to: 'testing_feedback#accept'
  post 'submit-feedback',                      to: 'testing_feedback#create'
  get 'search-suggestions',                    to: 'search#index', mode: :suggestions
  get 'search',                                to: 'search#index', as: :search, mode: :full
  get 'articles',                              to: 'articles#index', as: :articles
  get 'contact',                               to: 'contact#new'
  post 'contact',                              to: 'contact#create'

  get 'exchanges',				 					           to: 'exchanges#index'
  get 'exchange/:slug',				 			           to: 'exchanges#show', as: :exchange
  get 'user_exchanges',                        to: 'user_exchanges#index'
  get 'user_exchanges/:id',                    to: 'user_exchanges#index'
  post 'user_exchanges',                       to: 'user_exchanges#create'
  delete 'user_exchanges/:id',                 to: 'user_exchanges#destroy'
  get 'my-followers-of-exchange/:id',          to: 'user_exchanges#my_followers_of'
  get 'mute-exchange/:id',                     to: 'user_exchanges#mute'

  post 'interaction-mute',                     to: 'interaction_mutes#create'
  delete 'interaction-mute/:share_id',         to: 'interaction_mutes#destroy'

  get 'contributors',                          to: 'contributors#index'
  get 'contributor/:slug',                     to: 'contributors#show', as: :contributor
  get 'contributors/:slug',                    to: 'contributors#show'
  get 'sponsors',                              to: 'sponsors#index'
  get 'sponsor/:slug',                         to: 'sponsors#show', as: :sponsor

  post   'wp-connector/:model',                to: 'wp_connector#model_save'
	delete 'wp-connector/:model/:id',            to: 'wp_connector#model_delete'
  post   'wp-connector/:model/:id/unpublish',  to: 'wp_connector#model_delete'

  post 'register',                             to: 'register#create'

  get 'email-availability',                    to: 'email_availability#new'
  get 'username-availability',                 to: 'username_availability#new'
  get 'profile/new',                           to: 'profile_wizard#new', as: :profile_wizard
  post 'my-profile',                           to: 'profile_wizard#create', as: :save_profile_wizard
  post 'my-profile/:id',                       to: 'profile_wizard#create'

  get 'my-profile',                            to: 'users#show', as: :my_profile, me: true
  get 'account-settings',                      to: 'account_settings#edit'
  put 'account-settings',                      to: 'account_settings#update'
  put 'update-email',                          to: 'account_settings#update_email'
  put 'update-password',                       to: 'account_settings#update_password'
  get 'profile/:slug',                         to: 'users#show', as: :profile, identifier: :slug
  get 'profile-by-id/:id',                     to: 'users#show', identifier: :id
  put 'my-profile',                            to: 'users#update'
  put 'my-photo',                              to: 'users#update_photo'

  get 'user_followings',                       to: 'user_followings#index'
  get 'user_followings/:id',                   to: 'user_followings#index'
  post 'user_followings',                      to: 'user_followings#create'
  delete 'user_followings/:id',                to: 'user_followings#destroy'
  get 'follow-suggestions',                    to: 'profile_suggestions#index'
  get 'suggestion-search',                     to: 'profile_suggestions#index'
  get 'connects',                              to: 'connects#index'
  get 'my-followers-of-user/:id',              to: 'user_followings#my_followers_of'
  get 'mute-followed/:id',                     to: 'user_followings#mute'

  get 'my-home',                               to: 'front_page#index', as: :front_page
  get 'account-settings',                      to: 'account_settings#edit'

  get 'user_shares',                           to: 'user_shares#index'
  get 'user_shares/:id',                       to: 'user_shares#index'
  get 'user_ratings',                          to: 'user_ratings#index'
  get 'user_ratings/:id',                      to: 'user_ratings#index'
  get 'share/:id',                             to: 'shares#show'
  post 'share',                                to: 'shares#create', as: :share
  delete 'delete-share',                       to: 'shares#destroy'

  get 'comments',                              to: 'comments#index', as: :comments
  get 'comments/:id',                          to: 'comments#show', as: :comment
  post 'comments',                             to: 'comments#create'
  delete 'delete-comment',                     to: 'comments#destroy'
  get 'user_comments',                         to: 'user_comments#index'
  get 'user_comments/:id',                     to: 'user_comments#index'

  get 'opinions',                              to: 'opinions#index', as: :opinions
  get 'opinions/:id',                          to: 'opinions#show', as: :opinion
  post 'opinions',                             to: 'opinions#create'
  get 'user_opinions',                         to: 'user_opinions#index'
  get 'user_opinions/:id',                     to: 'user_opinions#index'
  get 'opinionators-of-share/:share_id',       to: 'user_shares#opinionators'
  get 'commenters-of-share/:share_id',         to: 'user_shares#commenters'

  get 'notifications',                         to: 'notifications#index', as: :notifications
  put 'notification/:id',                      to: 'notifications#update'
  get 'notification-count',                    to: 'notifications#index', as: :notification_count, count: true
  get 'all-notification-comments/:id',         to: 'notifications#commenters'
  get 'all-notification-opinions/:id',         to: 'notifications#opinionators'
  get 'all-notification-followers/:id',        to: 'notifications#followers'
  get 'follow-groups/:id',                     to: 'follow_groups#show', as: :follow_group

  post 'concern-reports',                      to: 'concern_reports#create'

  get 'mutes',                                 to: 'mutes#index'
  post 'mutes',                                to: 'mutes#create'
  delete 'mutes/:id',                          to: 'mutes#destroy'
  get 'blocks',                                to: 'blocks#index'
  post 'blocks',                               to: 'blocks#create'
  delete 'blocks/:id',                         to: 'blocks#destroy'

  put 'deactivate',                            to: 'account_settings#deactivate'
  put 'reactivate',                            to: 'account_settings#reactivate'
  delete 'delete-account',                     to: 'account_settings#destroy'

  put 'notification-settings',                 to: 'notification_settings#update'
  put 'communication-preferences',             to: 'communication_preferences#update'

  post 'third_party_article',                  to: 'third_party_articles#show'
  get 'check_third_party_whitelist',           to: 'third_party_articles#check_white_list'
  post 'submit_third_party_article',           to: 'third_party_articles#create'

  namespace :admin do
    resources :users
    get 'set_users_per_page', to: 'users#set_records_per_page'
    get 'add_user_to_blacklist', to: 'users#add_to_blacklist'
    get 'add_user_to_watchlist', to: 'users#add_to_watchlist'
    get 'deactivate_user', to: 'users#deactivate'
    get 'reactivate_user', to: 'users#reactivate'
    delete 'delete_user', to: 'users#destroy'
    delete 'destroy_user', to: 'users#destroy', destroy: true
    resources :concern_reports
    resources :user_concern_reports
    resources :comment_concern_reports
    resources :share_concern_reports
    get 'mark_concern_report_as_seen', to: 'concern_reports#update'
    resources :watch_list_users
    resources :black_list_users
    resources :concern_reports
    resources :quarantined_third_party_shares
    get 'approve_quarantined_third_party_share', to: 'quarantined_third_party_shares#approve'
    get 'reject_quarantined_third_party_share', to: 'quarantined_third_party_shares#reject'
    get 'delete_quarantined_third_party_share', to: 'quarantined_third_party_shares#delete'
    resources :white_listed_third_party_publishers
    root to: "users#index"
  end

  get 'feed', to: 'articles#index', :defaults => { :format => 'rss' }
  get "/sitemap.xml" => "sitemap#index", :format => "xml", :as => :sitemap

  PageRouter.load
	mount Sidekiq::Web, at: '/sidekiq'
  get "*slug", to: "articles#show", as: :article, constraints: lambda { |req|
    req.path.exclude? 'amazonaws.com'
  }
  post '*unmatched_route', to: 'application#render_404'
end
