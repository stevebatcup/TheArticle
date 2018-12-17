class AddSlugToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :slug, :string, after: :last_name
    add_index	:users, :slug
  end
end
