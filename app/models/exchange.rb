class Exchange < ApplicationRecord
	include WpCache
  mount_uploader :image, ExchangeImageUploader
  has_many :categorisations
  has_many :articles, through: :categorisations

  has_and_belongs_to_many  :users

  def is_followed_by(user)
    self.users.map(&:id).include?(user.id)
  end

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
    Rails.cache.fetch("trending_exchanges") do
        where.not(image: nil)
        .where(is_trending: true)
        .where("description > ''")
        .where("article_count > 0")
        .where("slug != 'editor-at-the-article'")
    end
  end

  def self.non_trending
    Rails.cache.fetch("non_trending_exchanges") do
        where.not(image: nil)
        .where(is_trending: false)
        .where("description > ''")
        .where("article_count > 0")
    end
  end

  def self.listings
      where.not(image: nil)
      .where("article_count > 0")
      .where("description > ''")
      .where("slug != 'editor-at-the-article'")
  end

  def is_editor_item?
    self.slug == 'editor-at-the-article'
  end

  def self.editor_item
    Rails.cache.fetch("exchange_editor_item") do
      where("slug = 'editor-at-the-article'").first
    end
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

    # update counter cache column
    update_article_count

    # bust caches
    ["trending_exchanges"].each do |cache_key|
      puts "busting cache: #{cache_key}"
      Rails.cache.delete(cache_key)
    end
  end

  def update_exchange_image(json)
  	remote_wp_image_id = json["exchange-image-id"].to_i
  	if remote_wp_image_id > 0
  		unless self.wp_image_id && (self.wp_image_id == remote_wp_image_id)
        self.wp_image_id = remote_wp_image_id
  			image_json = self.class.get_from_wp_api("media/#{remote_wp_image_id}")
        self.remote_image_url = image_json["source_url"]
  		end
  	else
      self.wp_image_id = nil
      self.image = nil
  	end
  end

  def articles_for_carousel
    articles = self.articles
                  .includes(:author).references(:author)
                  .includes(:exchanges).references(:exchanges)
                  .not_sponsored
                  .order(Arel.sql('RAND()'))
                  .limit(12)

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
  end
end
