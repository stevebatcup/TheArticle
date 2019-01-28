class CreateQuarantinedThirdPartyShares < ActiveRecord::Migration[5.2]
  def change
    create_table :quarantined_third_party_shares do |t|
      t.integer :user_id
      t.string :url
      t.integer :status
      t.integer :article_id
      t.string :heading
      t.string :image
      t.text :snippet
      t.text :post

      t.timestamps
    end
  end
end
