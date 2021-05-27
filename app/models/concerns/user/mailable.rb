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

  def set_opted_into_weekly_newsletters(status)
    self.communication_preferences.find_by(preference: :newsletters_weekly).update_attribute(:status, status)
  end

  def set_opted_into_offers(status)
    self.communication_preferences.find_by(preference: :newsletters_offers).update_attribute(:status, status)
  end

  def unsubscribe_all_emails
    self.notification_settings.find_by(key: 'email_followers').update_attribute(:value, 'never')
    self.notification_settings.find_by(key: 'email_exchanges').update_attribute(:value, 'never')
    self.notification_settings.find_by(key: 'email_responses').update_attribute(:value, 'never')
    self.notification_settings.find_by(key: 'email_replies').update_attribute(:value, 'never')
    self.communication_preferences.find_by(preference: 'newsletters_weekly').update_attribute(:status, false)
    self.communication_preferences.find_by(preference: 'newsletters_offers').update_attribute(:status, false)
  end

  def send_weekly_categorisations_mail
    begin
      articles = []
      items = WeeklyUserMailItem.where(user_id: self.id, action_type: "categorisation").where("created_at >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)")
      items.each do |item|
        if categorisation = Categorisation.find_by(id: item.action_id)
          articles << categorisation.article unless articles.include?(categorisation.article)
        end
      end
      CategorisationsMailer.weekly(self, articles).deliver_now if articles.any?
    rescue Exception => e
      # DeveloperMailer.categorisation_mailout_exception(e).deliver_now
    end
    items.destroy_all
  end

  def send_daily_categorisations_mail
    begin
      articles = []
      items = DailyUserMailItem.where(user_id: self.id, action_type: "categorisation")
                                .where("created_at > DATE_SUB(CONCAT(CURDATE(), ' ', '17:00:00'), INTERVAL 1 DAY)")
      items.each do |item|
        if categorisation = Categorisation.find_by(id: item.action_id)
          articles << categorisation.article unless articles.include?(categorisation.article)
        end
      end
      CategorisationsMailer.daily(self, articles).deliver_now if articles.any?
    rescue Exception => e
      # DeveloperMailer.categorisation_mailout_exception(e).deliver_now
    end
    items.destroy_all
  end

	module ClassMethods
	end
end