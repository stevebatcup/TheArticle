class WordpressLog < ApiLog
	default_scope	{ where(service: :wordpress) }
	# serialize :request_data, JSON

	def admin_type
		self.request_method.humanize
	end

	def request_data_hash
		eval(self.request_data)
	end

	def admin_date
		if request_data_hash['modified_gmt']
			Time.parse(request_data_hash['modified_gmt']).strftime("%H:%I on %B %e, %Y")
		else
			nil
		end
	end

	def admin_article_title
		if request_data_hash['title']
			request_data_hash["title"]["rendered"]
		end
	end
end
