class AddAdminIdsToWatchAndBlacklist < ActiveRecord::Migration[5.2]
  def change
  	add_column	:watch_list_users, :added_by_admin_user_id, :integer
  	add_column	:black_list_users, :added_by_admin_user_id, :integer
  end
end
