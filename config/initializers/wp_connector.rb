WpConnector.configure do |config|
	if Rails.env == 'development'
		config.wordpress_url = "http://admin.thearticle.jazz/wp-json/wp/v2"
	  config.wordpress_basic_auth = { login: 'foo', password: 'bar' }
	else
	  config.wordpress_url = "https://staging.thearticle.com/wp-json/wp/v2"
	  config.wordpress_basic_auth = { login: 'londonbridge', password: 'B37ys0m2w' }
	end
  config.wp_connector_api_key = "Y9H3FFF2P91BX47"
  config.wp_api_paginated_models = %w(articles news_articles posts)
end