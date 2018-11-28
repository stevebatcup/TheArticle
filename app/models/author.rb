class Author < ApplicationRecord
	include WpCache
	has_many	:articles
	belongs_to	:author_role, foreign_key: :role_id

	def is_sponsor?
		self.author_role == AuthorRole.find_by(slug: 'sponsor')
	end

  def self.update_article_counts
    all.each do |a|
      a.update_attribute(:article_count, a.articles.size)
    end
  end

	def update_article_count
		self.update_attribute(:article_count, self.articles.size)
	end

	def self.contributors_for_spotlight
		contributor_role = AuthorRole.find_by(slug: 'contributor')
		self.joins(:articles)
				.where(author_role: contributor_role)
				.where("email NOT LIKE ?", '@thearticle.com')
				.distinct
				.limit(6)
	end

	def random_article(tag=nil)
		random_articles = self.articles.order("RAND()")
		random_articles = random_articles.includes(:keyword_tags).references(:keyword_tags).where("keyword_tags.slug = ?", tag) if tag
		random_articles.first
	end

	def self.sponsors
		@@sponsors ||= begin
			sponsor_role = AuthorRole.find_by(slug: 'sponsor')
			sponsors = self.where(author_role: sponsor_role)
		end
	end

	def self.get_sponsors_single_posts(tag=nil, limit=nil)
		sponsored_articles = []
		self.sponsors.each do |sponsor|
			if sponsor.articles.any?
				random_article = sponsor.random_article(tag)
				sponsored_articles << random_article unless random_article.nil?
			end
			break if limit && (sponsored_articles.size >= limit)
		end
		sponsored_articles.sort_by {|a| a.published_at}
	end

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

		# update counter cache
		update_article_count
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

	def post_count
		3
	end

end
