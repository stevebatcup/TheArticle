class CreateConversersAndMessages < ActiveRecord::Migration[5.2]
  def change
  	create_table :conversers, id: false do |t|
  		t.belongs_to	:chat, index: true, foreign_key: true
  		t.belongs_to	:user, index: true, foreign_key: true
  		t.boolean	:is_chat_initiator
  	end

    create_table :messages do |t|
      t.references :chat
      t.references :user
      t.text :body
      t.boolean :is_ice_breaker, default: false
      t.datetime :read_by_recipient_at, default: nil
    end
  end
end
