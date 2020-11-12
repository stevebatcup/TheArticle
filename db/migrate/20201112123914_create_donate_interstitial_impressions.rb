class CreateDonateInterstitialImpressions < ActiveRecord::Migration[5.2]
  def change
    create_table :donate_interstitial_impressions do |t|
      t.integer :user_id
      t.datetime :shown_at
    end
  end
end
