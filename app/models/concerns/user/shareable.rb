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
      well_written: "#{self.ratings.average("CASE WHEN `rating_well_written` = 1 THEN 0 ELSE `rating_well_written` END").to_i}%",
      valid_points: "#{self.ratings.average("CASE WHEN `rating_valid_points` = 1 THEN 0 ELSE `rating_valid_points` END").to_i}%",
      agree: "#{self.ratings.average("CASE WHEN `rating_agree` = 1 THEN 0 ELSE `rating_agree` END").to_i}%"
    }
  end

  module ClassMethods
  end
end