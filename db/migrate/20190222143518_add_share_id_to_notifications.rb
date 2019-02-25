class AddShareIdToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :share_id, :integer, after: :specific_type
  end
end
