class AddReasonToWatchListUsers < ActiveRecord::Migration[5.2]
  def change
  	remove_column :watch_list_users, :reason
    add_column :watch_list_users, :reason, :integer, after: :status, default: 0
  end
end
