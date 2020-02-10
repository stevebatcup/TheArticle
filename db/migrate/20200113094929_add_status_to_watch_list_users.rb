class AddStatusToWatchListUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :watch_list_users, :status, :integer, after: :reason, default: 0
  end
end
