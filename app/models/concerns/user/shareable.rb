module User::Shareable
  def self.included(base)
    base.extend ClassMethods
  end

  def share_onlys
  	self.shares.share_onlys
  end

  def ratings
  	self.shares.ratings
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
      well_written: BigDecimal(self.shares.average(:rating_well_written)).to_i,
      valid_points: BigDecimal(self.shares.average(:rating_valid_points)).to_i,
      agree: BigDecimal(self.shares.average(:rating_agree)).to_i
    }
  end

  module ClassMethods
  end
end