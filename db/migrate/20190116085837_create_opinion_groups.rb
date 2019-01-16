class CreateOpinionGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :opinion_groups do |t|
      t.integer :user_id
      t.integer :share_id
      t.text :body
      t.string :decision

      t.timestamps
    end

    add_column	:opinions, :opinion_group_id, :integer
  end
end
