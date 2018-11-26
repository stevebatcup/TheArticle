class Article < ApplicationRecord
	include WpCache
	has_one	:featured_image
	has_and_belongs_to_many	:exchanges
	has_and_belongs_to_many	:keyword_tags
	belongs_to :author

	def limited_exchanges(exchange_limit)
		self.exchanges.limit(exchange_limit)
	end

	def self.wp_type
		'posts'
	end

	def update_wp_cache(json)
		self.slug = json["slug"]
		self.title = json["title"]["rendered"]
		self.content = json["content"]["rendered"]
		self.excerpt = json["excerpt"]["rendered"]
		self.author_id = json["author"]
		self.published_at = Time.parse(json['date_gmt'])

		self.canonical_url = json["seo_fields"]["canonical"]
		self.page_title = json["seo_fields"]["title"]
		self.meta_description = json["seo_fields"]["description"]
		self.social_image = json["seo_fields"]["image"]
		self.robots_nofollow = json["seo_fields"]["nofollow"]
		self.robots_noindex = json["seo_fields"]["noindex"]

		update_author(json)
		update_featured_image(json)
		update_keyword_tags(json)
		update_exchanges(json)

    self.save
  end

  def update_author(json)
  	author_id = json["author"]
    author = Author.find_or_create_by(wp_id: author_id)
    author_json = self.class.get_from_wp_api("users/#{author_id}")
    author.update_wp_cache(author_json)
    self.author = author
  end

	def update_featured_image(json)
		featured_image_id = json["featured_media"].to_i
		if featured_image_id > 0
			unless self.featured_image && (self.featured_image == FeaturedImage.find_by_wp_id(featured_image_id))
				self.featured_image.destroy if self.featured_image
				image_json = self.class.get_from_wp_api("media/#{featured_image_id}")
				self.build_featured_image({
					wp_id: featured_image_id,
					url: image_json["source_url"]
				})
			end
		else
			self.featured_image.destroy if self.featured_image
		end
	end

	def update_keyword_tags(json)
		if json["tags"].any?
			self.keyword_tags.clear
			json["tags"].each do |tag_wp_id|
				tag = KeywordTag.find_or_create_by(wp_id: tag_wp_id)
				tag_json = self.class.get_from_wp_api("tags/#{tag_wp_id}")
		    tag.update_wp_cache(tag_json)
				self.keyword_tags << tag
			end
		end
	end

	def update_exchanges(json)
		if json["exchanges"].any?
			self.exchanges.clear
			json["exchanges"].each do |exchange_wp_id|
				exchange = Exchange.find_or_create_by(wp_id: exchange_wp_id)
				exchange_json = self.class.get_from_wp_api("exchanges/#{exchange_wp_id}")
		    exchange.update_wp_cache(exchange_json)
				self.exchanges << exchange
			end
		end
	end
end
