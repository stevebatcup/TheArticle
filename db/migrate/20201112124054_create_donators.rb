class CreateDonators < ActiveRecord::Migration[5.2]
  def change
    create_table :donators do |t|
      t.integer :user_id
      t.boolean :recurring

      t.timestamps
    end
  end
end
