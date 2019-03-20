module User::Mailable
  def self.included(base)
    base.extend ClassMethods
  end

  def opted_into_weekly_newsletters?
  	preference = self.communication_preferences.find_by(preference: "newsletters_weekly")
  	preference && preference.status
  end

  def opted_into_offers?
  	preference = self.communication_preferences.find_by(preference: "newsletters_offers")
  	preference && preference.status
  end

	module ClassMethods
	end
end