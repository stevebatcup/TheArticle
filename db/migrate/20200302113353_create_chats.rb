class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.integer :last_message_id
      t.integer :message_count

      t.timestamps
    end
  end
end
