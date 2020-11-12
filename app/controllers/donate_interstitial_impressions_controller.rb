class DonateInterstitialImpressionsController < ApplicationController
  def new
    DonateInterstitialImpression.create({
      user_id: current_user.id,
      shown_at: Time.now
    })
  end
end