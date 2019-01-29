class AddRatingFieldsToQuarantinedShares < ActiveRecord::Migration[5.2]
  def change
  	remove_column	:quarantined_third_party_shares, :image, :integer
  	add_column	  :quarantined_third_party_shares, :image, :string, :limit => 1000
  	add_column    :quarantined_third_party_shares, :rating_well_written, :integer, default: 0
  	add_column    :quarantined_third_party_shares, :rating_valid_points, :integer, default: 0
  	add_column    :quarantined_third_party_shares, :rating_agree, :integer, default: 0
  end
end
