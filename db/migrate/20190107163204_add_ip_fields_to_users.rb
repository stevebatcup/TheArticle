class AddIpFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :signup_ip_address, :string
    add_column :users, :signup_ip_city, :string
    add_column :users, :signup_ip_region, :string
    add_column :users, :signup_ip_country, :string
  end
end
