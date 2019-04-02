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

  def send_weekly_categorisations_mail
    articles = []
    items = WeeklyUserMailItem.where(user_id: self.id, action_type: "categorisation").where("created_at >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)")
    items.each do |item|
      if categorisation = Categorisation.find(item.action_id)
        articles << categorisation.article unless articles.include?(categorisation.article)
      end
    end
    CategorisationsMailer.weekly(self, articles).deliver_now if articles.any?
    # items.destroy_all
  end

  def send_daily_categorisations_mail
    articles = []
    items = DailyUserMailItem.where(user_id: self.id, action_type: "categorisation").where("DATE(created_at) = CURDATE()")
    items.each do |item|
      if categorisation = Categorisation.find(item.action_id)
        articles << categorisation.article unless articles.include?(categorisation.article)
      end
    end
    CategorisationsMailer.daily(self, articles).deliver_now if articles.any?
    # items.destroy_all
  end

	module ClassMethods
	end
end