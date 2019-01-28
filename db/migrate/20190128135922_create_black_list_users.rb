class CreateBlackListUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :black_list_users do |t|
      t.integer :user_id
      t.text :reason

      t.timestamps
    end
  end
end
