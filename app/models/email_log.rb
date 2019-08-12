class EmailLog < ApiLog
	default_scope	{ where(service: :mandrill) }
	serialize :response, JSON
	belongs_to	:user

	def request_data_hash
		eval(self.request_data)
	end

	def response_hash
		if self.response.nil?
			nil
		else
			self.response[0]
		end
	end

	def status
		response_hash["status"]
	end

	def subject
		request_data_hash[:subject]
	end

	def content
		request_data_hash[:html].html_safe
	end

	def admin_date
		self.created_at.strftime("%H:%M on %B %e, %Y")
	end
end
