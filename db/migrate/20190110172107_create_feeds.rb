class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
		create_table :feeds do |t|
      t.string  :user_id, references: :user
      t.integer :actionable_id
      t.string  :actionable_type
      t.timestamps
    end
    add_index :feeds, [:actionable_type, :actionable_id]
    add_index :feeds, [:user_id, :actionable_type, :actionable_id]
    add_index :feeds, :user_id
  end
end
