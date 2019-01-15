class AddNotificationCounterCacheToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_counter_cache, :integer
  end
end
