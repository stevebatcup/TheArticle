class CreateApiLogs < ActiveRecord::Migration[5.2]
  def change
  	create_table :api_logs do |t|
  	  t.string :service
  	  t.integer :user_id
  	  t.string :request_type
  	  t.string :request_method
  	  t.text :request_data
  	  t.text :response

  	  t.timestamps null: false
  	end

  	add_index :api_logs, :service
  	add_index :api_logs, :user_id
  	add_index :api_logs, :request_method
  end
end
