class AddPublishedAtToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :published_at, :datetime
  end
end
