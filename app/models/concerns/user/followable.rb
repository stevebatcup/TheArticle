module User::Followable
  def self.included(base)
    base.extend ClassMethods
  end

  def connects
    @connects ||= begin
      list = []
      self.followers.each do |follower|
        list << follower if follower.is_followed_by(self)
      end
      list
    end
  end

  def is_followed_by(user)
    self.followers.map(&:id).include?(user.id)
  end

  def followings_count
    Rails.cache.fetch("followings_count_#{self.id}") do
      self.followings.size
    end
  end

  def followers_count
    Rails.cache.fetch("followers_count_#{self.id}") do
      self.followers.size
    end
  end

  def recent_followings(hours=24)
    self.followings.where("created_at >= DATE_SUB(CURTIME(), INTERVAL #{hours} HOUR)").order("created_at DESC")
  end

  def recent_followeds(hours=24)
    self.fandoms.where("created_at >= DATE_SUB(CURTIME(), INTERVAL #{hours} HOUR)").order("created_at DESC")
  end

  def generate_follow_groups(hours=6)
    recent_follows = self.fandoms
                          .where("follows.created_at >= DATE_SUB(CURTIME(), INTERVAL #{hours} HOUR)")
                          .where(follow_group_id: nil)
                          .order("follows.created_at DESC")
    if recent_follows.size > 0
      body_text = FollowGroup.generate_body_text_from_followings(recent_follows)
      group = FollowGroup.new({user_id: self.id, body: body_text})
      recent_follows.each do |recent_follow|
        group.follows << recent_follow
      end
      group.save
    end
  end

  module ClassMethods
  end
end