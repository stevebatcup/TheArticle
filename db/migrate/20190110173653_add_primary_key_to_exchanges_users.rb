class AddPrimaryKeyToExchangesUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :exchanges_users, :id, :primary_key, before: :exchange_id
  end
end
