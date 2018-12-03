class EditExchangeImageFields < ActiveRecord::Migration[5.2]
  def change
  	add_column :exchanges, :image, :string, after: :description
    add_column :exchanges, :wp_image_id, :integer, after: :image
  	drop_table :exchange_images
  end
end
