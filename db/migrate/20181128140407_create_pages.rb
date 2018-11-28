class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.integer :wp_id
      t.string :title
      t.text :content
      t.string :slug
      t.text :meta_description

      t.timestamps
    end
  end
end
