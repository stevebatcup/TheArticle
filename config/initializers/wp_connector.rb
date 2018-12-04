WpConnector.configure do |config|
	if Rails.env == 'staging'
	  config.wordpress_url = "http://railstaging.thearticle.com/wp-json/wp/v2"
	else
		config.wordpress_url = "http://xadmin.thearticle.jazz/wp-json/wp/v2"
	end
	# puts "******** Env for WpConnector #{Rails.env} | #{config.wordpress_url} ********"
  config.wp_connector_api_key = "Y9H3FFF2P91BX47"
  config.wp_api_paginated_models = %w(articles news_articles posts)
end