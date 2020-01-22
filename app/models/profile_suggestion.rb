class ProfileSuggestion < ApplicationRecord
	belongs_to	:user
	belongs_to	:suggested, class_name: "User"

  def self.delete_suggested(user)
  	self.where(suggested_id: user.id).destroy_all
  end

  def self.archive_expired_for_user(user)
  	user.profile_suggestions
  			.where(author_article_count: 0)
  			.where("DATE(created_at) < DATE_SUB(CURDATE(), INTERVAL 10 WEEK)")
  			.each { |ps| ps.expire }
  end

  def follow
    self.user.profile_suggestion_archives.create({
      suggested_id: self.suggested_id,
      reason_for_archive: :followed
    })
    self.destroy
  end

  def expire
    self.user.profile_suggestion_archives.create({
      suggested_id: self.suggested_id,
      reason_for_archive: :expired
    })
    self.destroy
  end

  def ignore
  	self.user.profile_suggestion_archives.create({
  		suggested_id: self.suggested_id,
  		reason_for_archive: :ignored
  	})
  	self.destroy
  end
end
