class CreateThirdPartyShareErrorLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :third_party_share_error_logs do |t|
      t.text :url
      t.integer :user_id
      t.string :error_show_to_user
      t.text :exception_message

      t.timestamps
    end
  end
end
