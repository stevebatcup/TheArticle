module User::Suggestable
  def self.included(base)
    base.extend ClassMethods
  end

  def pending_suggestions
    self.profile_suggestions.includes(:suggested)
          .where(status: :pending)
          .where(author_article_count: 0)
          .where(users: { has_completed_wizard: true, status: User.statuses["active"] })
  end

  def pending_author_suggestions(limit=10)
    self.profile_suggestions.includes(:suggested)
          .where(status: :pending)
          .where("author_article_count > 0")
          .where.not(suggested_id: self.id)
          .limit(limit)
  end

  def paginated_pending_suggestions(page, per_page)
    self.profile_suggestions.where(status: :pending).page(page).per(per_page)
  end

  def generate_suggestions(is_new=false, limit=25)
    results = []
    existing_ids = self.profile_suggestions.map(&:suggested_id)
    existing_ids << self.id

    # People already following
    self.followings.each do |following|
      existing_ids << following.followed_id
    end

    # Following same exchanges
    self.exchanges.each do |exchange|
      exchange.users.active.where.not(id: existing_ids).limit(10).each do |exchange_user|
        unless existing_ids.include?(exchange_user.id)
          unless exchange_user.is_author?
            results << { user_id: exchange_user.id, reason: "exchange_#{exchange.id}", author_article_count: 0 }
            existing_ids << exchange_user.id
          end
        end
      end
    end

    if is_new
      # Generally Popular profiles
      self.class.popular_users(existing_ids).limit(30).each do |user|
        unless user.is_author?
          results << { user_id: user.id, reason: "popular_profile", author_article_count: 0 }
          existing_ids << user.id
        end
      end
    else
      # Popular with people you follow
      self.followings.limit(25).each do |following|
        following_user = following.followed
        following_user.followings.where.not(followed_id: existing_ids).limit(2).each do |their_following|
          unless their_following.followed.is_author?
            results << { user_id: their_following.followed.id, reason: "popular_with_following_#{following_user.id}", author_article_count: 0 }
            existing_ids << their_following.followed.id
          end
        end
      end

      # Same articles rated highly
      self.highly_rated_articles.each do |share|
        other_sharers = share.article.shares
                          .where.not(user_id: existing_ids)
                          .where("rating_well_written > 6 AND rating_valid_points > 6 AND rating_agree > 6 ")
                          .map(&:user)
        other_sharers.each do |os|
          unless os.is_author?
            results << { user_id: os.id, reason: "also_highly_rated_article_#{share.article.id}", author_article_count: 0 }
            existing_ids << os.id
          end
        end
      end
    end

    # de-dupe
    existing_ids.uniq!
    results.select! do |result|
      existing_ids.include?(result[:user_id])
    end

    results = results.shuffle.slice(0..limit)

    # now add the authors
    User.authors_by_article_count(existing_ids, 8).each do |author_user|
      results << { user_id: author_user.id, reason: "author", author_article_count: author_user.author.article_count }
      existing_ids << author_user.id
    end

    save_suggestions results
  end

  def save_suggestions(results)
    results.each do |result|
      self.profile_suggestions.build({
        suggested_id: result[:user_id],
        reason: result[:reason],
        author_article_count: result[:author_article_count],
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
      User.where('username LIKE :query or location LIKE :query', :query => "%#{query}%").where.not(id: current_user.id).where(status: :active).to_a
    end
  end
end