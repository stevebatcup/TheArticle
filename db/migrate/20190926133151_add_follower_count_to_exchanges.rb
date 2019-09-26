class AddFollowerCountToExchanges < ActiveRecord::Migration[5.2]
  def change
    add_column :exchanges, :follower_count, :integer, default: 0
  end
end
