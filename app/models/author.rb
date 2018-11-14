class Author < ApplicationRecord
	include WpCache
	has_many	:articles
	belongs_to	:author_role, foreign_key: :role_id

	def self.wp_type
		'users'
	end

	def update_wp_cache(json)
		self.wp_id = json["id"]
		self.display_name = json["name"]
		self.first_name = json["firstname"]
		self.last_name = json["lastname"]
		self.email = json["email_address"]
		self.blurb = json["blurb"]
		self.title = json["title"]
		self.url = json["url"]
		self.slug = json["slug"]
		self.twitter_handle = json["twitter_handle"]
		self.facebook_url = json["facebook_url"]
		self.instagram_username = json["instagram_username"]
		self.image_url = json["author_image"]
		update_author_role(json)
		self.save
	end

	def update_author_role(json)
		unless self.author_role && (self.author_role.slug == json["role"])
			json["role"] = json["role"] == 'journalist' ? 'contributor' : json["role"]
			if role = AuthorRole.find_by_slug(json["role"])
				self.author_role = role
			else
				self.build_author_role({
					name: json["role"].humanize,
					slug: json["role"]
				})
			end
		end
	end

end
