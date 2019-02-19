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

  def agree_with_post(share)
    Opinion.create({
      user_id: self.id,
      share_id: share.id,
      decision: 'agree'
    })
    undisagree_with_post(share)
  end

  def unagree_with_post(share)
    if opinion = Opinion.find_by(user_id: self.id, share_id: share.id, decision: 'agree')
      opinion.destroy
    end
  end

  def disagree_with_post(share)
    Opinion.create({
      user_id: self.id,
      share_id: share.id,
      decision: 'disagree'
    })
    unagree_with_post(share)
  end

  def undisagree_with_post(share)
    if opinion = Opinion.find_by(user_id: self.id, share_id: share.id, decision: 'disagree')
      opinion.destroy
    end
  end

  module ClassMethods
  end
end