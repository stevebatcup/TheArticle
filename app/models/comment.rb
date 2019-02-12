class Comment < ActiveRecord::Base
  has_many :feeds, as: :actionable
  has_many :notifications, as: :eventable
  has_many :concern_reports, as: :sourceable
  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  validates :body, :presence => true
  validates :user, :presence => true

  belongs_to :commentable, :polymorphic => true

  belongs_to :user
  before_create :create_feed
  before_destroy :delete_feeds

  def create_feed
    self.feeds.build({user_id: self.user_id})
  end

  def delete_feeds
    self.feeds.destroy_all
  end

  def create_notification
    is_reply = !self.parent.nil?
    self.notifications.create({
      user_id: is_reply ? self.parent.user_id : self.commentable.user_id,
      specific_type: is_reply ? "reply" : "comment",
      body: is_reply ? "<b>#{self.user.display_name}</b> replied to a comment on your post" : "<b>#{self.user.display_name}</b> commented on your post",
      feed_id: self.feeds.first.id
    })
  end

  def self.show_limit
    5
  end

  def self.show_reply_limit
    4
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

end
