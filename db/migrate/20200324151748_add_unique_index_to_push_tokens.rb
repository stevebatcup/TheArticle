class AddUniqueIndexToPushTokens < ActiveRecord::Migration[5.2]
  def change
  	add_index :push_tokens, :token, unique: true
  end
end
