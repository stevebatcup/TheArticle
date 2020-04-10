module User::Pushable
	def recieves_follow_pushes?
		return false if !has_active_status?
		ok_to_push = false
		if preference = self.notification_settings.find_by(key: :push_followers)
	  	ok_to_push = (preference.value == 'yes')
	  end
	  ok_to_push
	end

	def recieves_categorisation_pushes?
		return false if !has_active_status?
		ok_to_push = false
		if preference = self.notification_settings.find_by(key: :push_exchanges)
	  	ok_to_push = (preference.value == 'yes')
	  end
	  ok_to_push
	end

	def allow_all_pushes
		if exchanges_preference = self.notification_settings.find_by(key: :push_exchanges)
			exchanges_preference.update(value: "yes")
		end

		if followers_preference = self.notification_settings.find_by(key: :push_followers)
			followers_preference.update(value: "yes")
		end
	end
end
