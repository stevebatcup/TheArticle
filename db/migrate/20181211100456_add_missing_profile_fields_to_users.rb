class AddMissingProfileFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :title, :string, after: :id
    add_column :users, :profile_photo, :string, after: :location
    add_column :users, :cover_photo, :string, after: :profile_photo
    add_column :users, :bio, :text, after: :cover_photo
    add_column :users, :has_completed_wizard, :boolean, after: :last_name, default: false
  end
end
