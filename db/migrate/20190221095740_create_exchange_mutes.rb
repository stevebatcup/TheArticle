class CreateExchangeMutes < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_mutes do |t|
      t.integer :user_id
      t.integer :muted_id

      t.timestamps
    end
  end
end
