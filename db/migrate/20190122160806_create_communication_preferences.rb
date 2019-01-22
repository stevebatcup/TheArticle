class CreateCommunicationPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :communication_preferences do |t|
      t.integer :user_id
      t.string :preference
      t.boolean :status

      t.timestamps
    end
  end
end
