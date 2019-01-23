class CreateEmailAliasLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :email_alias_logs do |t|
      t.integer :user_id
      t.string :old_email
      t.string :new_email
      t.text :reason

      t.timestamps
    end
  end
end
