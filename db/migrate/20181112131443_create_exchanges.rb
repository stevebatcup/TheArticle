class CreateExchanges < ActiveRecord::Migration[5.2]
  def change
    create_table :exchanges do |t|
      t.integer :wp_id
      t.string :name
      t.string :slug
      t.text :description
      t.boolean :is_trending
      t.string :image_url

      t.timestamps null: false
    end

    create_table :articles_exchanges, id: false do |t|
      t.belongs_to :article, index: true, foreign_key: true
      t.belongs_to :exchange, index: true, foreign_key: true
    end
  end
end
