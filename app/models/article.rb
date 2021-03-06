class Article < ApplicationRecord
  has_and_belongs_to_many	:keyword_tags
  belongs_to :author, optional: true
  belongs_to :additional_author, optional: true, class_name: 'Author'

  has_many :shares

  has_many  :categorisations, dependent: :destroy
  has_many  :exchanges, through: :categorisations, dependent: :destroy

  before_create	:nullify_ratings_caches
  after_destroy :update_all_article_counts
  mount_uploader :image, ArticleImageUploader

  scope :not_remote, -> { where("remote_article_url = '' OR remote_article_url IS NULL") }
  scope :published, -> { where.not(published_at: nil) }
  scope :authored, -> { where("author_id IS NOT NULL") }

  include WpCache
  include Adminable

  def self.search(query, size=500)
    not_remote
      .published
      .authored
      .where("title LIKE '%#{query}%' OR excerpt LIKE '%#{query}%'")
      .order(published_at: :desc)
      .limit(size)
  end

  def self.most_rated(limit = 10, within_days = 7)
    Rails.cache.fetch('most_rated_articles', expires_in: 30.minutes) do
      items = select('COUNT(shares.id) AS rating_count, articles.*')
              .left_joins(:shares)
              .where("shares.share_type = 'rating'")
              .where("shares.created_at > DATE_SUB(CURDATE(), INTERVAL #{within_days} DAY)")
              .group(:id)
              .order('COUNT(shares.id) DESC')
              .to_a
      author_ids = []
      results = []
      items.each do |item|
        unless author_ids.include?(item.author_id)
          results << item
          author_ids << item.author_id
        end
        break if results.length == limit
      end
      results
    end
  end

  def self.schedule_create_or_update(wp_id, publish_date)
    if publish_date > Time.now
      unless fa = FutureArticle.find_by(wp_id: wp_id)
        fa = FutureArticle.new({ wp_id: wp_id })
      end
      fa.created_at = Time.zone.now unless fa.persisted?
      fa.updated_at = Time.zone.now
      fa.publish_date = publish_date
      fa.save
    else
      super(wp_id)
    end
  end

  def nullify_ratings_caches
    self.ratings_well_written_cache = nil
    self.ratings_valid_points_cache = nil
    self.ratings_agree_cache = nil
  end

  def recalculate_ratings_caches
    if ratings.nil?
      self.ratings_count = 0
      self.ratings_well_written_cache = nil
      self.ratings_valid_points_cache = nil
      self.ratings_agree_cache = nil
    else
      self.ratings_count = shares.where(share_type: 'rating').length
      self.ratings_well_written_cache = ratings[:well_written]
      self.ratings_valid_points_cache = ratings[:valid_points]
      self.ratings_agree_cache = ratings[:agree]
    end
    save
  end

  def has_ratings?
    !ratings_well_written_cache.nil? ||
      !ratings_valid_points_cache.nil? ||
      !ratings_agree_cache.nil?
  end

  def ratings
    @ratings ||= begin
      if shares.where(share_type: 'rating').any?
        {
          well_written: shares.average(:rating_well_written),
          valid_points: shares.average(:rating_valid_points),
          agree: shares.average(:rating_agree)
        }
      end
    end
  end

  def get_follows_average_ratings(user)
    items = shares.where(share_type: 'rating').where(user_id: user.followings.map(&:followed_id))
    if items.any?
      {
        well_written: items.average(:rating_well_written),
        valid_points: items.average(:rating_valid_points),
        agree: items.average(:rating_agree)
      }
    else
      {
        well_written: 0,
        valid_points: 0,
        agree: 0
      }
    end
  end

  def exchange_names
    exchanges.collect(&:name).join(' ')
  end

  def keyword_tags_names
    keyword_tags.collect(&:name).join(' ')
  end

  def strip_content
    ActionView::Base.full_sanitizer.sanitize(content)
  end

  def publish_month
    published_at.strftime('%B %Y')
  end

  def self.recent
    sponsors = Author.sponsors.to_a
    limit = sponsors.any? ? 5 : 6
    articles = Rails.cache.fetch('recent_unsponsored_articles', expires_in: 15.minutes) do
      not_sponsored.not_remote
                   .includes(:author).references(:author)
                   .order(published_at: :desc)
                   .limit(limit)
                   .all.to_a
    end
    if sponsors.any?
      sponsored_articles = sponsored
                           .includes(:author)
                           .references(:author)
                           .order(Arel.sql('RAND()'))
                           .limit(1)
      articles.insert(3, sponsored_articles.first) if sponsored_articles.any?
    end
    articles
  end

  def self.trending
    not_sponsored.not_remote
                 .includes(:keyword_tags).references(:keyword_tags)
                 .includes(:exchanges).references(:exchanges)
                 .includes(:author).references(:author)
                 .where("keyword_tags.slug = 'trending-article'")
  end

  def self.latest
    not_sponsored.not_remote
                 .includes(:keyword_tags).references(:keyword_tags)
                 .includes(:exchanges).references(:exchanges)
                 .includes(:author).references(:author)
                 .order('published_at DESC')
  end

  def self.for_carousel(sponsored_starting_position = 2)
    Rails.cache.fetch('article_carousel', expires_in: 10.minutes) do
      articles = trending
                 .includes(:exchanges).references(:exchanges)
                 .where.not(image: nil)
                 .order(published_at: :desc)
                 .limit(12)
                 .all.to_a

      carousel_articles = []
      carousel_articles_evens = []
      carousel_articles_odds = []
      articles.each_with_index do |article, i|
        if i.even?
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
      (0..halfway).each do |i|
        article = carousel_articles[i]
        shifted << article if article
      end
      shifted.each do |s|
        carousel_articles.delete(s)
      end
      carousel_articles += shifted

      sponsored_carousel_articles = Author.get_sponsors_single_posts('trending-article', 3)
      if sponsored_carousel_articles[0]
        carousel_articles.insert(sponsored_starting_position, sponsored_carousel_articles[0])
      end
      if sponsored_carousel_articles[1]
        carousel_articles.insert(sponsored_starting_position + 4, sponsored_carousel_articles[1])
      end
      if sponsored_carousel_articles[2]
        carousel_articles.insert(sponsored_starting_position + 8, sponsored_carousel_articles[2])
      end

      carousel_articles
    end
  end

  def is_newly_published?
    published_at >= 1.day.ago
  end

  def self.sponsored
    where(is_sponsored: true)
  end

  def self.not_sponsored
    where(is_sponsored: false)
  end

  def self.leading_editor_article
    Rails.cache.fetch('leading_editor_article') do
      not_sponsored.not_remote
                   .includes(:keyword_tags).references(:keyword_tags)
                   .includes(:exchanges).references(:exchanges)
                   .includes(:author).references(:author)
                   .where("keyword_tags.slug = 'leading-article'")
                   .where("exchanges.slug = 'editor-at-the-article'")
                   .order(published_at: :desc).first
    end
  end

  def self.editors_picks(page = 1, per_page = 6)
    editor_at_exchange_articles = Exchange.where(slug: 'editor-at-the-article').first.articles
    articles = not_sponsored.not_remote
                            .includes(:keyword_tags).references(:keyword_tags)
                            .includes(:exchanges).references(:exchanges)
                            .includes(:author).references(:author)
                            .where("keyword_tags.slug = 'editors-pick'")
                            .where.not(id: editor_at_exchange_articles)
                            .order(published_at: :desc)
    if page > 0
      if page == 1
        articles = articles.page(1).per(per_page - 1)
      else
        offset = (page - 1) * per_page - 1
        articles = articles.page(1).per(per_page).offset(offset)
      end
    end
    articles
  end

  def limited_exchanges(exchange_limit)
    exchanges.limit(exchange_limit)
  end

  def self.wp_type
    'posts'
  end

  def process_article_content_from_wp(json_content)
    fragment = Nokogiri::HTML.fragment(json_content).to_xhtml
  end

  def update_wp_cache(json)
    self.slug = json['slug']
    self.title = json['proper_title']
    self.content = process_article_content_from_wp(json['content']['rendered'])
    self.excerpt = json['excerpt']['rendered']
    self.author_id = json['author']
    self.published_at = Time.parse(json['date_gmt'])

    self.canonical_url = json['seo_fields']['canonical']
    self.page_title = json['seo_fields']['title']
    self.meta_description = json['seo_fields']['description']
    self.social_image = json['seo_fields']['image']
    self.robots_nofollow = json['seo_fields']['nofollow']
    self.robots_noindex = json['seo_fields']['noindex']

    is_new_article = !persisted?

    update_author(json)
    update_image(json)
    update_exchanges(json)
    update_keyword_tags(json)
    update_additional_author(json) if json['additional_author'] && json['additional_author'].to_i > 0

    if save
      # update counter cache columns
      update_all_article_counts
      update_is_sponsored_cache

      # bust caches
      %w[leading_editor_article article_carousel recent_unsponsored_articles].each do |cache_key|
        Rails.cache.delete(cache_key)
      end

      # build all notifications (feeds, notifications, pushes, emails)
      trigger_notification_jobs if is_new_article && categorisations.any?

      json['response_status'] = 'Success'
    else
      json['response_status'] = "Error: #{errors.full_messages.inspect}"
    end

    ApiLog.wordpress(is_new_article ? :publish_article : :update_article, self, json)
  end

  def trigger_notification_jobs
    ArticleCategorisationUpdateFeedsJob.set(wait_until: 30.seconds.from_now).perform_later(self)
    ArticleCategorisationBuildNotificationsJob.set(wait_until: 60.seconds.from_now).perform_later(self)
    ArticleCategorisationSendBrowserPushesJob.set(wait_until: 90.seconds.from_now).perform_later(self)
    ArticleCategorisationSendEmailsJob.set(wait_until: 120.seconds.from_now).perform_later(self)
  end

  def update_categorisation_feeds
    categorisations.each do |cat|
      cat.update_feeds
    end
    ApiLog.wordpress(:update_exchange_feeds, self)
  end

  def send_categorisation_email_notifications
    handled_users = []
    categorisations.shuffle.each do |cat|
      cat_users = cat.handle_email_notifications(handled_users)
      cat_users.each { |cu| handled_users << cu }
    end
    ApiLog.wordpress(:send_email_notifications, self)
  end

  def update_all_article_counts
    Author.update_article_counts
    KeywordTag.update_article_counts
    Exchange.update_article_counts
  end

  def update_is_sponsored_cache
    result = exchanges.include?(Exchange.sponsored_exchange)
    update_attribute(:is_sponsored, author.is_sponsor? && result)
    result
  end

  def update_author(json)
    author_id = json['author']
    author = Author.find_or_create_by(wp_id: author_id)
    author_json = self.class.get_from_wp_api("authors/#{author_id}")
    author.update_wp_cache(author_json)
    self.author = author
  end

  def update_additional_author(json)
    additional_author_id = json['additional_author']
    additional_author = Author.find_or_create_by(wp_id: additional_author_id)
    additional_author_json = self.class.get_from_wp_api("authors/#{additional_author_id}")
    additional_author.update_wp_cache(additional_author_json)
    self.additional_author = additional_author
  end

  def update_image(json)
    remote_wp_image_id = json['featured_media'].to_i
    if remote_wp_image_id > 0
      unless wp_image_id && (wp_image_id == remote_wp_image_id)
        self.wp_image_id = remote_wp_image_id
        image_json = self.class.get_from_wp_api("images/#{remote_wp_image_id}")
        self.remote_image_url = image_json['source_url']
        if image_json['caption'] && (image_json['caption'].length > 0)
          caption = ActionController::Base.helpers.strip_tags(image_json['caption'])
          self.image_caption = ActionController::Base.helpers.truncate(caption, length: 150)
        end
      end
    else
      self.wp_image_id = nil
      self.image = nil
    end
  end

  def update_keyword_tags(json)
    if json['tags'].any?
      keyword_tags.clear
      json['tags'].each do |tag_wp_id|
        tag = KeywordTag.find_or_create_by(wp_id: tag_wp_id)
        tag_json = self.class.get_from_wp_api("tags/#{tag_wp_id}")
        tag.update_wp_cache(tag_json)
        keyword_tags << tag
      end
    end
  end

  def update_exchanges(json)
    if json['exchanges'].any?
      json['exchanges'].each do |exchange_wp_id|
        exchange = Exchange.find_or_create_by(wp_id: exchange_wp_id)
        exchange_json = self.class.get_from_wp_api("exchanges/#{exchange_wp_id}")
        exchange.update_wp_cache(exchange_json)
        existing_categorisation_exchange_ids = categorisations.map(&:exchange_id)
        unless existing_categorisation_exchange_ids.include?(exchange.id)
          categorisations << Categorisation.new({ exchange_id: exchange.id, created_at: Time.now })
        end
      end
    end
  end

  def self.content_ad_slots(article, is_mobile, ad_page_type, ad_page_id, ad_publisher_id, include_display_ads = true, include_video_ads = true)
    ads = []
    if is_mobile && include_display_ads
      ads = [
        {
          position: 7,
          ad_type_id: 1,
          ad_page_id: ad_page_id,
          ad_page_type: ad_page_type,
          ad_publisher_id: ad_publisher_id,
          ad_classes: 'ads_box text-center my-2',
          ad_name: 'sidecolumn'
        },
        {
          position: 11,
          ad_type_id: 1,
          ad_page_id: ad_page_id,
          ad_page_type: ad_page_type,
          ad_publisher_id: ad_publisher_id,
          ad_classes: 'ads_box text-center my-2',
          ad_name: 'sidecolumn'
        }
      ]
    end

    if include_video_ads
      unless article.is_sponsored
        ads.push({
                   position: 3,
                   ad_type_id: 4,
                   ad_page_id: ad_page_id,
                   ad_page_type: ad_page_type,
                   ad_publisher_id: ad_publisher_id,
                   ad_classes: 'unruly_video ads_box text-center',
                   ad_name: 'unruly'
                 })
      end
    end

    ads
  end

  def self.purge(wp_id) # delete article from WP
    article = unscoped.where(wp_id: wp_id).first!
    article.purge_self
  rescue StandardError
    logger.warn "Could not purge Article with id #{wp_id}, no record with that id was found."
  end

  def purge_self
    # shares
    share_ids = shares.map(&:id)
    Feed.where(actionable_type: 'Share').where(actionable_id: share_ids).destroy_all
    FeedUser.where(action_type: 'share').where(source_id: share_ids).destroy_all
    shares.destroy_all
    # categorisations
    cat_ids = categorisations.map(&:id)
    Feed.where(actionable_type: 'Categorisation').where(actionable_id: cat_ids).destroy_all
    FeedUser.where(action_type: 'categorisation').where(source_id: id).destroy_all
    categorisations.destroy_all
    # article
    destroy
  end

  def self.calculate_sponsored_ids_for_page(page, sponsored_per_page = 3)
    sponsored_ids = Article.sponsored.order(published_at: :desc).map(&:id)
    set = sponsored_ids
    (page - 1).times { shifted = set.shift(sponsored_per_page); set += shifted }
    set[0..(sponsored_per_page - 1)]
  end

  def self.views_before_interstitial
    0
  end

  def self.recent_within_exchanges(exchange_ids)
    not_sponsored.not_remote
                 .includes(:keyword_tags).references(:keyword_tags)
                 .includes(:exchanges).references(:exchanges)
                 .includes(:author).references(:author)
                 .where(exchanges: { id: exchange_ids })
                 .order(published_at: :desc)
  end
end
