class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.integer :wp_id
      t.string :display_name
      t.string :role_id
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :slug
      t.string :url
      t.string :title
      t.text :blurb
      t.string :twitter_handle
      t.string :facebook_url
      t.string :instagram_username

      t.timestamps
    end
  end
end
