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

  def article_share(article)
    share = self.shares.where(article_id: article.id)
    if share.any?
      share.first
    else
      nil
    end
  end

  def highly_rated_articles
    self.shares.where("rating_well_written > 6 AND rating_valid_points > 6 AND rating_agree > 6 ")
  end

  def ratingsSummary
    @ratingsSumary ||= {
      article_count: self.shares.size,
      well_written: summarise_rating_item(self.shares.average(:rating_well_written)),
      valid_points: summarise_rating_item(self.shares.average(:rating_valid_points)),
      agree: summarise_rating_item(self.shares.average(:rating_agree))
    }
  end

  def summarise_rating_item(item)
    item.nil? ? 0 : BigDecimal(item).to_i
  end

  module ClassMethods
  end
end