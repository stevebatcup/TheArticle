module User::Shareable
  def self.included(base)
    base.extend ClassMethods
  end

  def share_onlys
  	self.shares.share_onlys.order(created_at: :desc)
  end

  def ratings
  	self.shares.ratings.order(created_at: :desc)
  end

  def ratings_count
    self.ratings.size
  end

  def existing_article_rating(article)
    rating_share = self.shares.where(article_id: article.id).where(share_type: 'rating').first
    if rating_share.present?
      rating_share
    else
      nil
    end
  end

  def highly_rated_articles
    self.shares.where("rating_well_written >= 75 AND rating_valid_points >= 75 AND rating_agree >= 75 ")
  end

  def ratings_summary
    @ratings_summary ||= {
      article_count: self.ratings.size,
      well_written: "#{self.ratings.average(:rating_well_written)}",
      valid_points: "#{self.ratings.average(:rating_valid_points)}",
      agree: "#{self.ratings.average(:rating_agree)}"
    }
  end

  def set_share_counts
    self.share_all_count = self.shares.size
    self.share_ratings_count = ratings_count
    self.save
  end

  def posts
    self.shares.where("post > ''")
  end

  module ClassMethods
    def set_all_share_counts
      User.all.each { |user| user.set_share_counts }
    end
  end
end