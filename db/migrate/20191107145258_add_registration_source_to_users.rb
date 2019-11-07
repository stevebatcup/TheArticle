class AddRegistrationSourceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :registration_source, :string, default: :website
  end
end
