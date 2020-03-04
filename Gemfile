source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.0'

gem "rack", ">= 2.0.8"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
# Use Puma as the app server
gem "puma", ">= 3.12.2"
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem "excon", ">= 0.71.0"

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

gem "font-awesome-rails"

# Cron
gem 'whenever', require: false

# Email APIs
gem 'mandrill-api'
gem 'mailchimp-api'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'sidekiq', '~> 5.2.0'

# Connect to Wordpress
gem 'wp-connector', :git => 'git@github.com:stevebatcup/wp-connector.git'
gem 'sinatra', require: false
gem 'slim'

# browser detection
gem 'browser'

# Bower for JS libs
gem "bower-rails", "~> 0.11.0"

gem "nokogiri", ">= 1.10.4"
gem 'thinking-sphinx', '~> 4.0'

# Upload images
gem "mini_magick", ">= 4.9.4"
gem "carrierwave"
gem "carrierwave-base64"
gem "fog-aws"

gem 'redis-rails'
gem 'unicorn'

gem 'devise', ">= 4.7.1"
gem 'angularjs-rails'
gem 'angularjs-rails-resource', '~> 2.0.0'
# gem 'angular-rails-templates'

gem 'kaminari'
gem 'geocoder'

gem "acts_as_commentable_with_threading"
gem 'mustache'

gem "administrate", '>= 0.10.0'
gem 'administrate_collapsible_navigation'
gem 'administrate-field-date_picker', '~> 0.1.0'
gem 'administrate-field-enum'
gem "wysiwyg-rails"
# gem "administrate-field-nested_has_many", git: "https://github.com/NedelescuVlad/administrate-field-nested_has_many"

gem "ogp", '0.2.1', :git => 'git@github.com:stevebatcup/ogp.git'
gem 'faraday_middleware'

gem 'exception_notification'

gem "recaptcha"
gem "rest-client"
gem "rss"
gem 'fcm'

gem "rubyzip", ">= 1.3.0"
gem "loofah", ">= 2.3.1"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'rspec-rails'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  # Deployment
  gem "capistrano", "3.11.0", require: false
  gem "capistrano-rails", "~> 1.3", require: false
  gem 'capistrano-rbenv', '~> 2.1'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'rails-controller-testing'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
