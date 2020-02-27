class AddPrivateLocationToUsers < ActiveRecord::Migration[5.2]
	def self.up
		add_column :users, :private_location, :string, after: :location
    User.update_all("private_location=location")
  end

  def self.down
  	remove_column :users, :private_location, :string, after: :location
  end
end