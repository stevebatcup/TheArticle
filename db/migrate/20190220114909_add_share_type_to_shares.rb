class AddShareTypeToShares < ActiveRecord::Migration[5.2]
  def change
    add_column :shares, :share_type, :string, after: :id, default: 'rating'
  end
end
