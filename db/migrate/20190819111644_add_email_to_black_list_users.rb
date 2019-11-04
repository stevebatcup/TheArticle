class AddEmailToBlackListUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :black_list_users, :email, :string, after: :user_id
  end
end
