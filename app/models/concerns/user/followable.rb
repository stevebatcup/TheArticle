module User::Followable
  def self.included(base)
    base.extend ClassMethods
  end

  def follow_counts_as_hash
    {
      followings: self.followings_count,
      followers: self.followers_count,
      connections: self.connections_count
    }
  end

  def recalculate_follow_counts
    self.followings_count = self.followings.size
    self.followers_count = self.followers.active.size
    self.connections_count = connects.size
    self.save
  end

  def connects
    @connects ||= begin
      list = []
      self.followers.active.each do |follower|
        list << follower if follower.is_followed_by(self)
      end
      list
    end
  end

  def is_followed_by(user)
    self.followers.map(&:id).include?(user.id)
  end

  def im_following_same_count(other_user)
    items = other_user.followers.to_a
    items.select! do |f|
      f.is_followed_by(self)
    end
    items.size
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

  def mute_followed(id)
    self.follow_mutes.create({muted_id: id})
  end

  def send_followed_mail_if_opted_in(follower)
    preference = self.notification_settings.find_by(key: :email_followers)
    if preference
      if preference.value == 'as_it_happens'
        FollowsMailer.as_it_happens(self, follower).deliver_now
      elsif preference.value == 'daily'
        DailyUserMailItem.create({
          user_id: self.id,
          action_type: 'follow',
          action_id: follower.id
        })
      elsif preference.value == 'weekly'
        WeeklyUserMailItem.create({
          user_id: self.id,
          action_type: 'follow',
          action_id: follower.id
        })
      end
    end
  end

  def send_weekly_follows_mail
    followers = []
    follow_items = WeeklyUserMailItem.where(user_id: self.id, action_type: "follow").where("created_at >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)")
    follow_items.each do |item|
      if user = User.active.find_by(id: item.action_id)
        followers << user
      end
    end
    FollowsMailer.daily_and_weekly(self, followers).deliver_now if followers.any?
    follow_items.destroy_all
  end

  def send_daily_follows_mail
    followers = []
    follow_items = DailyUserMailItem.where(user_id: self.id, action_type: "follow").where("DATE(created_at) = CURDATE()")
    follow_items.each do |item|
      if user = User.active.find_by(id: item.action_id)
        followers << user
      end
    end
    FollowsMailer.daily_and_weekly(self, followers).deliver_now if followers.any?
    follow_items.destroy_all
  end

  module ClassMethods
  end
end