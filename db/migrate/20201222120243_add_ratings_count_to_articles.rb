class AddRatingsCountToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :ratings_count, :integer, after: :is_sponsored, default: 0
  end
end
