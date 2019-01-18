class CreateBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :blocks do |t|
      t.integer :user_id
      t.integer :blocked_id

      t.timestamps
    end
  end
end
