class AddWpImageIdToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :wp_image_id, :integer, after: :image
  end
end
