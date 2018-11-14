class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.integer :wp_id
      t.string :title
      t.integer :author_id
      t.text :content
      t.string :slug
      t.text :excerpt

      t.timestamps
    end
  end
end
