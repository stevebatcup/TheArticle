class WordpressLog < ApiLog
	default_scope	{ where(service: :wordpress) }

	def admin_type
		self.request_method.humanize
	end

	def request_data_hash
		eval(self.request_data)
	end

	def admin_date
		self.created_at.strftime("%H:%M on %B %e, %Y")
	end

	def admin_article_title
		if request_data_hash['proper_title']
			request_data_hash["proper_title"]
		elsif request_data_hash['title']
			request_data_hash["title"]["rendered"]
		end
	end
end
