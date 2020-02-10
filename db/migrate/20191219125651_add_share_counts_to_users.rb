class AddShareCountsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :share_all_count, :integer, default: 0, after: :connections_count
    add_column :users, :share_ratings_count, :integer, default: 0, after: :share_all_count
  end
end
