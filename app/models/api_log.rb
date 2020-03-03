class ApiLog < ApplicationRecord
	def self.request(**params)
		params.merge!({request_type: :request})
		create(params)
	end

	def self.webhook(**params)
		params.merge!({request_type: :webhook})
		create(params)
	end

	def self.wordpress(request_method, article, json={})
		request_data = json.empty? ? { "article_id" => article.id, "modified_gmt" => "#{Time.now}", "proper_title" => article.title.html_safe } : json
		create({
			request_type: :webhook,
			service: :wordpress,
			user_id: 0,
			request_method: request_method,
			request_data: request_data,
			response: nil
		})
	end
end
