class DonateInterstitialImpression < ApplicationRecord
  def self.find_latest_for_user(user)
    items = where(user_id: user.id).order(shown_at: :asc)
    return nil if items.nil?

    items.last
  end
end
