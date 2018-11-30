class Article < ApplicationRecord
	include WpCache
	has_one	:featured_image
	has_and_belongs_to_many	:exchanges
	has_and_belongs_to_many	:keyword_tags
	belongs_to :author
	after_destroy :update_all_article_counts

	searchable do
		text :title, boost: 3
		text :strip_content, :publish_month
		text :keyword_tags do
			keyword_tags.map(&:name)
		end
		text :exchanges do
			exchanges.map(&:name)
		end
	end

	def strip_content
		ActionView::Base.full_sanitizer.sanitize(self.content)
	end

	def publish_month
	  published_at.strftime("%B %Y")
	end

	def self.recent
		sponsors = Author.sponsors
		limit = sponsors.any? ? 5 : 6
		articles = self.not_sponsored
									.order(published_at: :desc)
									.limit(limit)
									.all.to_a

		if sponsors.any?
			sponsored_articles = self.sponsored
																.order("RAND()")
																.limit(1)
			articles.insert(3, sponsored_articles.first) if sponsored_articles.any?
		end

		articles
	end

	def self.trending
		self.not_sponsored
			.includes(:keyword_tags).references(:keyword_tags)
			.includes(:exchanges).references(:exchanges)
			.includes(:author).references(:author)
			.includes(:featured_image).references(:featured_image)
			.where("keyword_tags.slug = 'trending-article'")
	end

	def self.for_carousel(sponsored_starting_position=2)
		articles = self.trending
      .where.not(featured_images: {id: nil})
			.order(published_at: :desc)
			.limit(12)
			.all.to_a

		carousel_articles = []
		carousel_articles_evens = []
		carousel_articles_odds = []
		articles.each_with_index do |article, i|
			if i % 2 == 0
				carousel_articles_evens << article
			else
				carousel_articles_odds << article
			end
		end

		carousel_articles_evens.each_with_index do |even_article, i|
			odd_article = carousel_articles_odds[i]
			carousel_articles.unshift even_article
			carousel_articles.push odd_article if odd_article
		end

		shifted = []
		halfway = (carousel_articles.length / 2).ceil - 2
		for i in 0..halfway do
			article = carousel_articles[i]
			shifted << article if article
		end
		shifted.each do |s|
			carousel_articles.delete(s)
		end
		carousel_articles = carousel_articles + shifted

		sponsored_carousel_articles = Author.get_sponsors_single_posts('trending-article', 3)
		if sponsored_carousel_articles[0]
			carousel_articles.insert(sponsored_starting_position, sponsored_carousel_articles[0])
		end
		if sponsored_carousel_articles[1]
			carousel_articles.insert(sponsored_starting_position+4, sponsored_carousel_articles[1])
		end
		if sponsored_carousel_articles[2]
			carousel_articles.insert(sponsored_starting_position+8, sponsored_carousel_articles[2])
		end

		carousel_articles
	end

	def is_newly_published?
		published_at >= 1.day.ago
	end

	def self.sponsored
		self.where(is_sponsored: true)
	end

	def self.not_sponsored
		self.where(is_sponsored: false)
	end

	def self.leading_editor_article
		self.not_sponsored
			.includes(:keyword_tags).references(:keyword_tags)
			.includes(:exchanges).references(:exchanges)
			.includes(:author).references(:author)
			.where("keyword_tags.slug = 'leading-article'")
			.where("exchanges.slug = 'editor-at-the-article'")
			.order(published_at: :desc)
			.limit(1)
			.first
	end

	def self.editors_picks
		editor_articles = Exchange.where(slug: 'editor-at-the-article').first.articles
		self.not_sponsored
			.includes(:exchanges).references(:exchanges)
			.includes(:author).references(:author)
			.where.not(:id => editor_articles)
			.limit(17)
	end

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

    # update counter caches
    update_all_article_counts
    update_is_sponsored_cache
  end

  def update_all_article_counts
    Author.update_article_counts
    Exchange.update_article_counts
  end

  def update_is_sponsored_cache
  	result = self.exchanges.include?(Exchange.sponsored_exchange)
  	self.update_attribute(:is_sponsored, self.author.is_sponsor? && result)
  	result
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

	def self.content_ad_slots(is_mobile=true, ad_page_type, ad_page_id)
		if is_mobile
			ads = [
				{
					position: 3,
					ad_type_id: 4,
					ad_page_id: ad_page_id,
					ad_page_type: ad_page_type,
					ad_classes: 'unruly_video ads_box text-center my-2'
				},
				{
					position: 7,
					ad_type_id: 1,
					ad_page_id: ad_page_id,
					ad_page_type: ad_page_type,
					ad_classes: 'ads_box text-center my-2'
				},
				{
					position: 11,
					ad_type_id: 1,
					ad_page_id: ad_page_id,
					ad_page_type: ad_page_type,
					ad_classes: 'ads_box text-center my-2'
				}
			]
		else
			ads = [
				{
					position: 3,
					ad_type_id: 4,
					ad_page_id: ad_page_id,
					ad_page_type: ad_page_type,
					ad_classes: 'unruly_video ads_box text-center'
				}
			]
		end
		ads
	end
end
