class AddIsNewAndIsSeenToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :is_new, :boolean
    add_column :notifications, :is_seen, :boolean
    add_index	:notifications, :is_new
  end
end
