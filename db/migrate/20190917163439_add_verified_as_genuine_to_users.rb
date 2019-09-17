class AddVerifiedAsGenuineToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :verified_as_genuine, :boolean, default: false, after: :display_name
  end
end
