WpConnector.configure do |config|
  config.wordpress_url = "http://admin.thearticle.jazz/wp-json/wp/v2"
  config.wp_connector_api_key = "Y9H3FFF2P91BX47"
  config.wp_api_paginated_models = %w(articles news_articles posts)
end