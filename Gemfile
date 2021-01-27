source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.0'

gem 'rack', '>= 2.0.8'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.2'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.5.3', '< 0.6.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem 'excon', '>= 0.71.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'font-awesome-rails'

# Cron
gem 'whenever', require: false

# Email APIs
gem 'mailchimp-api'
gem 'mandrill-api'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'sidekiq', '~> 5.2.0'

# Connect to Wordpress
gem 'sinatra', require: false
gem 'slim'
gem 'wp-connector', git: 'git@github.com:stevebatcup/wp-connector.git'

# browser detection
gem 'browser'

# Bower for JS libs
gem 'bower-rails', '~> 0.11.0'

gem 'nokogiri', '>= 1.10.4'
gem 'thinking-sphinx', '~> 4.0'

# Upload images
gem 'carrierwave'
gem 'carrierwave-base64'
gem 'fog-aws'
gem 'mini_magick', '>= 4.9.4'

gem 'redis-rails'
gem 'unicorn'

gem 'angularjs-rails'
gem 'angularjs-rails-resource', '~> 2.0.0'
gem 'devise', '>= 4.7.1'
# gem 'angular-rails-templates'

gem 'geocoder'

gem 'acts_as_commentable_with_threading'
gem 'mustache'

gem 'administrate', '>= 0.13.0'
gem 'administrate_collapsible_navigation'
gem 'administrate-field-belongs_to_search'
gem 'administrate-field-date_picker', '~> 0.1.0'
gem 'administrate-field-enum'
gem 'wysiwyg-rails'
# gem "administrate-field-nested_has_many", git: "https://github.com/NedelescuVlad/administrate-field-nested_has_many"

gem 'faraday_middleware'
gem 'ogp', '0.2.1', git: 'git@github.com:stevebatcup/ogp.git'

gem 'exception_notification'

gem 'fcm'
gem 'recaptcha', '5.6.0'
gem 'rest-client'
gem 'rss'

gem 'loofah', '>= 2.3.1'
gem 'rubyzip', '>= 1.3.0'

gem 'actionpack', '>= 5.2.4.3'
gem 'activestorage', '>= 5.2.4.3'
gem 'activesupport', '>= 5.2.4.3'
gem 'kaminari', '>= 1.2.1'
gem 'puma', '>= 4.3.5'
gem 'websocket-extensions', '>= 0.1.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'rspec-rails'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Deployment
  gem 'capistrano', '3.11.0', require: false
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-rbenv', '~> 2.1'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'factory_girl_rails'
  gem 'rails-controller-testing'
end
