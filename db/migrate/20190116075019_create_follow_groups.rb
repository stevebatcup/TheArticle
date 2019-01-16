class CreateFollowGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :follow_groups do |t|
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end

  add_column	:follows, :follow_group_id, :integer
end
