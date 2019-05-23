class CreatePendingFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :pending_follows do |t|
      t.integer :user_id
      t.integer :followed_id
      t.integer :follow_id
    end
  end
end