class AddIndexesToFeeds < ActiveRecord::Migration[5.2]
  def change
    add_index :feed_users_feeds, [:feed_user_id, :feed_id]
    add_index :feed_users, :user_id
    add_index :feed_users, :source_id
    add_index :feed_users, [:user_id, :source_id]
    add_index :feeds_notifications, [:notification_id, :feed_id]
  end
end
