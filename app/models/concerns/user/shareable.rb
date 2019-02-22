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
    rating = self.shares.where(article_id: article.id).where(share_type: 'rating')
    if rating.any?
      rating.first
    else
      nil
    end
  end

  def highly_rated_articles
    self.shares.where("rating_well_written > 6 AND rating_valid_points > 6 AND rating_agree > 6 ")
  end

  def ratings_summary
    @ratings_summary ||= {
      article_count: self.ratings.size,
      well_written: summarise_rating_item(self.ratings.average(:rating_well_written)),
      valid_points: summarise_rating_item(self.ratings.average(:rating_valid_points)),
      agree: summarise_rating_item(self.ratings.average(:rating_agree))
    }
  end

  def summarise_rating_item(item)
    item.nil? ? 0 : Article.format_rating_percentage(item)
  end

  module ClassMethods
  end
end