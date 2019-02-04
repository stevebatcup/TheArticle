class RenameWhitelistUrl < ActiveRecord::Migration[5.2]
  def change
  	rename_column :white_listed_third_party_publishers, :url, :domain
  end
end
