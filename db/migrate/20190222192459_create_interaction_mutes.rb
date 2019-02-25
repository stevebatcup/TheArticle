class CreateInteractionMutes < ActiveRecord::Migration[5.2]
  def change
    create_table :interaction_mutes do |t|
      t.integer :user_id
      t.integer :share_id

      t.timestamps
    end
  end
end
