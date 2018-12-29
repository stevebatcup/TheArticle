class CreateProfileSuggestions < ActiveRecord::Migration[5.2]
  def change
    create_table :profile_suggestions do |t|
      t.integer :user_id
      t.integer :suggested_id
      t.string :reason
      t.integer :status

      t.timestamps
    end
  end
end
