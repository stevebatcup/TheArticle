class AddImageCaptionToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :image_caption, :string, after: :image
  end
end
