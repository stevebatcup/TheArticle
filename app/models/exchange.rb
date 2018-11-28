class Exchange < ApplicationRecord
	include WpCache
	has_and_belongs_to_many	:articles
	has_one	:exchange_image

  def self.sponsored_exchange
    find_by(slug: 'sponsored')
  end

  def self.update_article_counts
    all.each do |e|
      e.update_attribute(:article_count, e.articles.size)
    end
  end

  def update_article_count
    self.update_attribute(:article_count, self.articles.size)
  end

  def self.trending_list
    includes(:exchange_image).references(:exchange_image)
      .where.not(exchange_images: {id: nil})
      .where(is_trending: true)
      .where("description > ''")
      .where("article_count > 0")
      .order("RAND()")
  end

  def self.listings
    includes(:exchange_image).references(:exchange_image)
      .where.not(exchange_images: {id: nil})
      .where("article_count > 0")
      .where("description > ''")
      .where("slug != 'editor-at-the-article'")
      .order(:name)
  end

  def self.editor_item
    where("slug = 'editor-at-the-article'").first
  end

	def self.wp_type
		'exchanges'
	end

	def update_wp_cache(json)
		self.name = json["name"]
		self.description = json["description"]
		self.slug = json["slug"]
		self.is_trending = !(json["is_trending"].to_i.zero?)
		update_exchange_image(json)
    self.save

    # update counter cache
    update_article_count
  end

  def update_exchange_image(json)
  	exchange_image_id = json["exchange-image-id"].to_i
  	if exchange_image_id > 0
  		unless self.exchange_image && (self.exchange_image == ExchangeImage.find_by_wp_id(exchange_image_id))
  			self.exchange_image.destroy if self.exchange_image
  			image_json = self.class.get_from_wp_api("media/#{exchange_image_id}")
  			self.build_exchange_image({
  				wp_id: exchange_image_id,
  				url: image_json["source_url"]
  			})
  		end
  	else
			self.exchange_image.destroy if self.exchange_image
  	end
  end
end
