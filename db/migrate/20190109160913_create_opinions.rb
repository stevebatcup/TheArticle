class CreateOpinions < ActiveRecord::Migration[5.2]
  def change
    create_table :opinions do |t|
      t.integer :user_id
      t.integer :share_id
      t.string :decision

      t.timestamps
    end
  end
end
