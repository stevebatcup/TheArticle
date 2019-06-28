class SortPushSubFields < ActiveRecord::Migration[5.2]
  def change
  	remove_column	:users, :push_sub, :string

  	create_table :push_tokens do |t|
  		t.integer	:user_id
  		t.string	:token
  		t.string	:browser
  		t.string	:device
  		t.datetime	:created_at
  	end
  end
end
