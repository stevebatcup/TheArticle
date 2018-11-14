class CreateExchangeImages < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_images do |t|
      t.integer :wp_id
      t.integer :exchange_id
      t.string :url

      t.timestamps
    end

    remove_column	:exchanges, :image_url, :string
  end
end
