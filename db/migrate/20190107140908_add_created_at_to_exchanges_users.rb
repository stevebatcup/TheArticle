class AddCreatedAtToExchangesUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :exchanges_users, :created_at, :datetime
  end
end
