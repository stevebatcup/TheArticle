class AddHandledByAdminUserIdToQuarantinedThirdPartyShares < ActiveRecord::Migration[5.2]
  def change
    add_column :quarantined_third_party_shares, :handled_by_admin_user_id, :integer, default: nil
  end
end
