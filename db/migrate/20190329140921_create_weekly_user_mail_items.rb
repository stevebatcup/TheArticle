class CreateWeeklyUserMailItems < ActiveRecord::Migration[5.2]
  def change
    create_table :weekly_user_mail_items do |t|
      t.integer :user_id
      t.string :action_type
      t.integer :action_id

      t.timestamps
    end

    add_index	:weekly_user_mail_items, :user_id
    add_index	:weekly_user_mail_items, :created_at
  end
end
