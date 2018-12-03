class PrepareAuthorsForImages < ActiveRecord::Migration[5.2]
  def change
  	remove_column :authors, :image_url, :string
  	add_column :authors, :image, :string, after: :slug
    add_column :authors, :wp_image_id, :integer, after: :image
  end
end
