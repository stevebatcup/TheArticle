class CreateAdditionalEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_emails do |t|
      t.integer :user_id
      t.string :text

      t.timestamps
    end
  end
end
