class AddAuthorIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :author_id, :integer, default: nil
  end
end
