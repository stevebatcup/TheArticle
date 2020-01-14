class CreateUserAdminNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :user_admin_notes do |t|
      t.integer :user_id
      t.integer :admin_user_id
      t.text :note

      t.timestamps
    end
  end
end
