class KeywordTag < ApplicationRecord
	include WpCache
	has_and_belongs_to_many	:articles

	def self.exclude_special
		where.not(slug: special_tags)
	end

	def self.special_tags
		['editors-pick', 'sponsored-pick', 'trending-article', 'leading-article']
	end

	def self.wp_type
		'tags'
	end

	def update_wp_cache(json)
		self.name = json["name"]
		self.description = json["description"]
		self.slug = json["slug"]
    self.save

    # update counter cache column
    update_article_count
  end

  def self.update_article_counts
    all.each do |kt|
      kt.update_attribute(:article_count, kt.articles.size)
    end
  end

  def update_article_count
    self.update_attribute(:article_count, self.articles.size)
  end

end