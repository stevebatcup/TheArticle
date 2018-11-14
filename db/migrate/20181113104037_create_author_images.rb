class CreateAuthorImages < ActiveRecord::Migration[5.2]
  def change
    create_table :author_images do |t|
      t.integer :wp_id
      t.integer :author_id
      t.string :url

      t.timestamps
    end
  end
end
