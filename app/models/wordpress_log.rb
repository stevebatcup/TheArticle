class WordpressLog < ApiLog
	default_scope	{ where(service: :wordpress) }
	# serialize :request_data, JSON

	def admin_type
		self.request_method.gsub(/_article/, '').capitalize
	end

	def request_data_hash
		eval(self.request_data)
	end

	def admin_date
		Time.parse(request_data_hash['modified_gmt'])
	end

	def admin_article_title
		request_data_hash["title"]["rendered"]
	end
end
