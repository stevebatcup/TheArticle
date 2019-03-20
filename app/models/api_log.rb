class ApiLog < ApplicationRecord
	def self.request(**params)
		params.merge!({request_type: :request})
		create(params)
	end

	def self.webhook(**params)
		params.merge!({request_type: :webhook})
		create(params)
	end
end
