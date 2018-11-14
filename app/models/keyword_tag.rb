class KeywordTag < ApplicationRecord
	include WpCache
	has_and_belongs_to_many	:articles

	def self.wp_type
		'tags'
	end

	def update_wp_cache(json)
		self.name = json["name"]
		self.description = json["description"]
		self.slug = json["slug"]
    self.save
  end
end