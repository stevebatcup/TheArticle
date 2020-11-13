class CreateDonations < ActiveRecord::Migration[5.2]
  def change
    create_table :donations do |t|
      t.integer :user_id
      t.boolean :recurring
      t.decimal :amount, precision: 10, scale: 2
      t.timestamps
    end
  end
end
