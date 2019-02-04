class CreateAccountDeletions < ActiveRecord::Migration[5.2]
  def change
    create_table :account_deletions do |t|
      t.integer :user_id
      t.string :reason
      t.boolean :by_admin, deafult: false

      t.datetime	:created_at
    end
  end
end
