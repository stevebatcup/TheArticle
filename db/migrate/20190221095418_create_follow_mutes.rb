class CreateFollowMutes < ActiveRecord::Migration[5.2]
  def change
    create_table :follow_mutes do |t|
      t.integer :user_id
      t.integer :muted_id

      t.timestamps
    end
  end
end
