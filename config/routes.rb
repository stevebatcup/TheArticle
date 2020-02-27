require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations", sessions: "sessions", passwords: "passwords" }
  devise_scope :user do
    post "set-stored-location", to: 'sessions#set_stored_location'
  end
  root 'home#index'
  get 'cookie-acceptance',                     to: 'cookie_acceptance#new'
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
  post 'exchanges_from_wizard',                to: 'profile_wizard#save_exchanges'

  post 'interaction-mute',                     to: 'interaction_mutes#create'
  delete 'interaction-mute/:share_id',         to: 'interaction_mutes#destroy'

  get 'contributors',                          to: 'contributors#index'
  get 'contributor/:slug',                     to: 'contributors#show', as: :contributor
  get 'contributors/:slug',                    to: 'contributors#show'
  get 'contributor_ratings/:id',               to: 'contributor_ratings#show'
  get 'contributor_ratings',                   to: 'contributor_ratings#index'
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
  get 'admin-profile-by-id/:id',               to: 'users#show', identifier: :id, from_admin: true
  put 'my-profile',                            to: 'users#update'
  put 'my-photo',                              to: 'users#update_photo'
  get 'profile/search-by-username',            to: 'users#search_by_username'
  get 'profile/search-by-username/:username',  to: 'users#search_by_username'

  get 'user_followings',                       to: 'user_followings#index'
  get 'user_followings/:id',                   to: 'user_followings#index'
  post 'user_followings',                      to: 'user_followings#create'
  delete 'user_followings/:id',                to: 'user_followings#destroy'
  get 'follow-suggestions',                    to: 'profile_suggestions#index'
  get 'suggestion-search',                     to: 'profile_suggestions#index'
  post 'ignore-suggestion',                    to: 'profile_suggestions#update'
  get 'connects',                              to: 'connects#index'
  get 'my-followers-of-user/:id',              to: 'user_followings#my_followers_of'
  get 'mute-followed/:id',                     to: 'user_followings#mute'

  get 'my-home',                               to: 'front_page#index', as: :front_page
  get 'ratings-history/:id',                   to: 'ratings_history#show', as: :ratings_history
  get 'ratings-history',                       to: 'ratings_history#index'
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
    resources :authors
    resources :help_sections
    resources :help_contents
    get 'set_users_per_page', to: 'users#set_records_per_page'
    get 'add_user_to_blacklist', to: 'users#add_to_blacklist'
    get 'add_user_to_watchlist', to: 'users#add_to_watchlist'
    get 'create-account-page/:user_id', to: 'users#create_page'
    get 'get-open-pages', to: 'users#get_open_pages'
    get 'close-page/:user_id', to: 'users#close_page'
    get 'deactivate_user', to: 'users#deactivate'
    get 'reactivate_user', to: 'users#reactivate'
    delete 'delete_user', to: 'users#destroy'
    delete 'destroy_user', to: 'users#destroy', destroy: true
    resources :articles
    delete 'purge_article', to: 'articles#purge', destroy: true
    # concern_reports
    resources :concern_reports
    resources :user_concern_reports
    resources :comment_concern_reports
    resources :share_concern_reports
    resources :processed_concern_reports
    get 'mark_concern_report_as_seen', to: 'concern_reports#update'
    # watch_list
    resources :pending_watch_list_users
    resources :in_review_watch_list_users
    delete 'remove_from_watch_list/:id', to: 'watch_list_users#remove'
    delete 'delete_watch_list_account/:id', to: 'watch_list_users#delete_account'
    post 'send_watch_list_item_to_review/:id', to: 'pending_watch_list_users#send_to_review'
    resources :black_list_users
    resources :concern_reports
    resources :quarantined_third_party_shares
    resources :approved_third_party_shares
    resources :rejected_third_party_shares
    resources :wordpress_logs
    resources :email_logs
    resources :exchanges
    resources :landing_pages
    resources :keyword_tags
    get 'approve_quarantined_third_party_share', to: 'quarantined_third_party_shares#approve'
    get 'reject_quarantined_third_party_share', to: 'quarantined_third_party_shares#reject'
    get 'delete_quarantined_third_party_share', to: 'quarantined_third_party_shares#delete'
    resources :white_listed_third_party_publishers
    get 'available_authors_for_user/:user_id', to: 'users#available_authors'
    post 'set_author_for_user', to: 'users#set_author_for_user'
    post 'set_genuine_verified_for_user', to: 'users#set_genuine_verified_for_user'
    post 'add_additional_email', to: 'users#add_additional_email'
    delete 'delete_additional_email', to: 'users#delete_additional_email'
    post 'add_linked_account', to: 'users#add_linked_account'
    delete 'delete_linked_account', to: 'users#delete_linked_account'
    post 'update-user-bio', to: 'users#update_bio'
    post 'send-email', to: 'users#send_email'
    post 'add-note', to: 'users#add_note'
    delete 'delete-note/:id', to: 'users#delete_note'
    delete 'remove_photo/:photo_type/:user_id', to: 'users#remove_photo'
    put 'update-user-photo', to: 'users#update_photo'
    get 'send-new-photo-alert-email/:photo_type/:user_id', to: 'users#send_new_photo_alert_email'
    delete 'delete-post/:id', to: 'users#delete_post'
    resources :shares
    resources :comments
    root to: "users#index"
  end

  get 'feed', to: 'articles#index', :defaults => { :format => 'rss' }
  get 'feed/rss', to: 'articles#index', :defaults => { :format => 'rss' }
  get "/sitemap.xml" => "sitemap#index", :format => "xml", :as => :sitemap

  post "mailchimp-callback", to: 'mailchimp_callbacks#update'
  get "mailchimp-callback", to: 'mailchimp_callbacks#show'

  post "push_registrations", to: 'push_registrations#create'
  get "help", to: 'help_centre#index'
  get "help-feedback/:question_id/:outcome", to: 'help_feedback#new'
  post "push_registrations", to: 'push_registrations#create'

  post "push_registrations",   to: 'push_registrations#create'
  delete "push_registrations", to: 'push_registrations#destroy'

  post "push_registrations",   to: 'push_registrations#create'
  delete "push_registrations", to: 'push_registrations#destroy'

  PageRouter.load
  LandingPageRouter.load

	mount Sidekiq::Web, at: '/sidekiq'
  get "*slug", to: "articles#show", as: :article, constraints: lambda { |req|
    req.path.exclude? 'amazonaws.com'
  }
  post '*unmatched_route', to: 'application#render_404'
end
