class AddAdminLevelToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :admin_level, :integer, after: :last_name, default: 0
  end
end
