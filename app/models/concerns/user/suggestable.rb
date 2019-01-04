module User::Suggestable
  def self.included(base)
    base.extend ClassMethods
  end

  def pending_suggestions
    self.profile_suggestions.where(status: :pending)
  end

  def generate_suggestions(is_new=false, limit=25)
    results = []
    existing_ids = self.profile_suggestions.where(status: :pending).map(&:suggested_id)
    existing_ids << self.id

    # People already following
    self.followings.each do |following|
      existing_ids << following.followed_id
    end

    # Following same exchanges
    self.exchanges.each do |exchange|
      exchange.users.where.not(id: existing_ids).limit(10).each do |exchange_user|
        results << { user_id: exchange_user.id, reason: "exchange_#{exchange.id}" }
        existing_ids << exchange_user.id
      end
    end

    if is_new
      # Generally Popular profiles
      self.class.popular_users(existing_ids).limit(10).each do |user|
        results << { user_id: user.id, reason: "popular_profile "}
        existing_ids << user.id
      end
    else
      # Popular with people you follow
      self.followings.limit(10).each do |following|
        following_user = following.followed
        following_user.followings.where.not(followed_id: existing_ids).limit(2).each do |their_following|
          results << { user_id: their_following.followed.id, reason: "popular_with_following_#{following_user.id}" }
          existing_ids << their_following.followed.id
        end
      end

      # Same articles rated highly
      self.highly_rated_articles.each do |share|
        other_sharers = share.article.shares
                          .where.not(user_id: existing_ids)
                          .where("rating_well_written > 6 AND rating_valid_points > 6 AND rating_agree > 6 ")
                          .map(&:user)
        other_sharers.each do |os|
          results << { user_id: os.id, reason: "also_highly_rated_article_#{share.article.id}" }
          existing_ids << os.id
        end
      end
    end

    # TODO: Same location

    save_suggestions results.shuffle.slice(0..limit)
  end

  def save_suggestions(results)
    results.each do |result|
      self.profile_suggestions.build({
        suggested_id: result[:user_id],
        reason: result[:reason],
        status: :pending
      })
    end
    self.save
  end

  def accept_suggestion_of_user_id(user_id)
    if suggestion = self.profile_suggestions.find_by(suggested_id: user_id)
      suggestion.update_attribute(:status, :accepted)
    end
    true
  end

  module ClassMethods
    def search_for_suggestions(current_user, query)
      User.where('username LIKE :query or location LIKE :query', :query => "%#{query}%").to_a
    end
  end
end