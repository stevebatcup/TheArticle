class AddUniqueIndexToExchangesUsersAndProfileSuggestions < ActiveRecord::Migration[5.2]
  def change
  	add_index :exchanges_users, [:exchange_id, :user_id], unique: true
  	add_index :profile_suggestions, [:suggested_id, :user_id], unique: true
  end
end

