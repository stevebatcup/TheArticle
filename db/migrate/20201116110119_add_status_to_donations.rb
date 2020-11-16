class AddStatusToDonations < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :status, :integer, default: 0
  end
end
