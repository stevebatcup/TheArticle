class Page < ApplicationRecord
	include WpCache

	def self.wp_type
		'pages'
	end

	def update_wp_cache(json)
		self.slug = json["slug"]
		self.title = json["title"]["rendered"]
		self.content = json["content"]["rendered"]
		self.meta_description = json["seo_fields"]["description"]
    self.save
  end
end
