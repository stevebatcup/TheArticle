class AddUniqueIndexToExchangesUsers < ActiveRecord::Migration[5.2]
  def change
  	add_index :exchanges_users, [:exchange_id, :user_id], unique: true
  end
end
