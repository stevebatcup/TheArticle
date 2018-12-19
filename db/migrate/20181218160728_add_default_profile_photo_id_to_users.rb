class AddDefaultProfilePhotoIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :default_profile_photo_id, :integer, after: :profile_photo
  end
end
