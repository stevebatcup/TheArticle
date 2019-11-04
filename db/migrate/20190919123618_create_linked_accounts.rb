class CreateLinkedAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :linked_accounts do |t|
      t.integer :user_id
      t.integer :linked_account_id

      t.timestamps
    end
  end
end
