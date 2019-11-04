class Comment < ActiveRecord::Base
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
  has_many :concern_reports, as: :sourceable
  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  validates :body, :presence => true
  validates :user, :presence => true

  belongs_to :commentable, :polymorphic => true

  belongs_to :user
  after_create :create_feed
  after_create  :notify_mentioned_users

  before_destroy :delete_feeds_and_notifications

  def create_feed
    feed = self.feeds.create({user_id: self.user_id})
    self.user.followers.each do |follower|
      followers_blocked_ids = follower.blocked_id_list
      unless (self.parent && followers_blocked_ids.include?(self.parent.user.id))
        unless user_feed_item = FeedUser.find_by(user_id: follower.id, action_type: 'comment', source_id: self.commentable_id)
          user_feed_item = FeedUser.new({
            user_id: follower.id,
            action_type: 'comment',
            source_id: self.commentable_id
          })
        end
        user_feed_item.created_at = Time.now unless user_feed_item.persisted?
        user_feed_item.updated_at = Time.now
        user_feed_item.feeds << feed
        user_feed_item.save
      end
    end
  end

  def delete_feeds_and_notifications
    self.feeds.destroy_all
    self.notifications.destroy_all
  end

  def create_notification
    is_reply = !self.parent.nil?

    unless self.commentable.user_id == self.user_id
      # Notification for original sharer
      notification = Notification.find_or_create_by({
        eventable_type: 'Comment',
        specific_type: "comment",
        share_id: self.commentable.id,
        user_id: self.commentable.user_id,
        feed_id: nil
      })
      notification.eventable_id = self.id
      notification.feeds << self.feeds.first
      notification.body = ApplicationController.helpers.group_user_comment_feed_item(notification, false, true)
      notification.created_at = Time.now unless notification.persisted?
      notification.updated_at = Time.now
      notification.is_new = true
      notification.is_seen = false
      notification.save
    end

    if is_reply
      unless (self.commentable.user_id == self.parent.user_id) || (self.user_id == self.parent.user_id)
        # Reply notification for commenter
        reply_notification = Notification.find_or_create_by({
          eventable_type: 'Comment',
          specific_type: "reply",
          share_id: self.commentable.id,
          user_id: self.parent.user_id,
          feed_id: nil
        })
        reply_notification.eventable_id = self.id
        reply_notification.feeds << self.feeds.first
        reply_notification.body = ApplicationController.helpers.group_user_comment_feed_item(reply_notification, true, true)
        reply_notification.created_at = Time.now unless reply_notification.persisted?
        reply_notification.updated_at = Time.now
        reply_notification.is_new = true
        reply_notification.is_seen = false
        reply_notification.save
      end

    end
  end

  def self.show_limit
    10
  end

  def self.show_reply_limit
    15
  end

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    new \
      :commentable => obj,
      :body        => comment,
      :user_id     => user_id
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.any?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def self.order_list_by(comments, order_by=:most_relevant, current_user=nil)
    if order_by == :most_relevant
      unless current_user.nil?
        following_ids = current_user.followings.map(&:followed_id)
        fol_comments = comments.select { |c| following_ids.include?(c.user_id) }
        fol_comments.sort_by! { |c| [-c.children.size, -(c.created_at.to_i)] }.to_a
        non_fol_comments = comments.reject { |c| following_ids.include?(c.user_id) }
        non_fol_comments.sort_by! { |c| [-c.children.size, -(c.created_at.to_i)] }.to_a
        list = fol_comments + non_fol_comments
      else
        list = comments.sort_by { |c| -c.children.size }.to_a
      end
    elsif order_by == :most_recent
      list = comments.order(created_at: :desc).to_a
    elsif order_by == :oldest
      list = comments.order(created_at: :asc).to_a
    end
    list
  end

  def notify_mentioned_users
    if self.body.length > 0
      body_html =  Nokogiri::HTML.fragment(self.body)
      body_html.css('span.mentioned_user').each do |span|
        other_user_id = span.attributes["data-user"].value.to_i
        notification_suffix = (self.commentable.user_id == self.user_id) ? "on their own post" : "on a post by <a href='/profile/#{self.commentable.user.slug}'><b>#{self.commentable.user.display_name}</b> <span class='text-muted'>#{self.commentable.user.username}</span></a>"
        Notification.create({
          user_id: other_user_id,
          eventable_id: self.id,
          eventable_type: "CommentMentioner",
          share_id: self.commentable_id,
          body: "<a href='/profile/#{self.user.slug}'><b>#{self.user.display_name}</b> <span class='text-muted'>#{self.user.username}</span></a> mentioned you in a comment #{notification_suffix}",
          created_at: Time.now,
          updated_at: Time.now
        })
      end
    end
  end

end
