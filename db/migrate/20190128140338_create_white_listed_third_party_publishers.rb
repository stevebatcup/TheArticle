class CreateWhiteListedThirdPartyPublishers < ActiveRecord::Migration[5.2]
  def change
    create_table :white_listed_third_party_publishers do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
