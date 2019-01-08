module User::Followable
  def self.included(base)
    base.extend ClassMethods
  end

  def is_followed_by(user)
    self.followers.map(&:id).include?(user.id)
  end

  def recent_followings(hours=24)
    self.followings.where("created_at >= DATE_SUB(CURTIME(), INTERVAL #{hours} HOUR)").order("created_at DESC")
  end

  def recent_followeds(hours=24)
    self.fandoms.where("created_at >= DATE_SUB(CURTIME(), INTERVAL #{hours} HOUR)").order("created_at DESC")
  end

  module ClassMethods
  end
end