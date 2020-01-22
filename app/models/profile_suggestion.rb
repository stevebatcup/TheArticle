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

  def shared_followers_sentence
    Rails.cache.fetch("suggestion_shared_followers_sentence_#{self.id}", expires_in: 2.days) do
      members = []
      sentence = ""
      self.user.followings.each do |following|
        followee = following.followed
        members << followee if followee.followings.map(&:followed_id).include?(self.suggested_id)
      end

      if members.any?
        if members.length == 1 || browser.device.mobile?
          sentence << "<div class='single'><img src='#{members[0].profile_photo.url(:square)}'' class='rounded-circle over' /></div>
                      <p>Followed by <b>#{members[0].display_name}</b></p>"
        elsif members.length == 2
          sentence << "<div class='double'><img src='#{members[0].profile_photo.url(:square)}'' class='rounded-circle over' /><img src='#{members[1].profile_photo.url(:square)}'' class='rounded-circle under' /></div>
                        <p>Followed by <b>#{members[0].display_name}</b> and <b>#{members[1].display_name}</b></p>"
        else
          other_count = members.size - 2
          sentence << "<div class='double'><img src='#{members[0].profile_photo.url(:square)}'' class='rounded-circle over' /><img src='#{members[1].profile_photo.url(:square)}'' class='rounded-circle under' /></div>
                        <p>Followed by <b>#{members[0].display_name}</b>, <b>#{members[1].display_name}</b> and #{other_count} #{pluralize_without_count(other_count, 'other')} you know</p>"
        end
      end
      sentence
    end
  end
end
