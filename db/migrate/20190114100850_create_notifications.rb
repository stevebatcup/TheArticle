class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :user_id, references: :user
      t.string :title
      t.integer :eventable_id
      t.string :eventable_type
      t.string :specific_type
      t.integer :feed_id, references: :feed
      t.text :body

      t.timestamps
    end

    add_index :notifications, [:eventable_type, :eventable_id]
    add_index :notifications, :user_id
  end
end
