class AddUniqueIndexToFollows < ActiveRecord::Migration[5.2]
  def change
  	add_index :follows, [:followed_id, :user_id], unique: true
  end
end
