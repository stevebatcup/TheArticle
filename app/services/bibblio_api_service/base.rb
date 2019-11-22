module BibblioApiService
	class Base

		def self.api_host
			"https://api.bibblio.org/v1"
		end

		def log(action, url, user=nil, response='')
			ApiLog.request({
				service: :bibblio,
				user_id: user.present? ? user.id : 0,
				request_method: action,
				request_data: { url: url, access_token: access_token },
				response: response
			})
		end

		def client_id(env=:production)
			@client_id ||= Rails.application.credentials.bibblio[env][:client_id]
		end

		def client_secret(env=:production)
			@client_secret ||= Rails.application.credentials.bibblio[env][:client_secret]
		end

		def json_headers(env=:production)
			{
			  'Content-Type': 'application/json',
			  'Authorization': "Bearer #{access_token(env)}"
			}
		end

		def full_article_url(article)
			article.remote_article_url.present? ? article.remote_article_url : "https://www.thearticle.com/#{article.slug}"
		end

		def access_token(env=:production)
			@access_token ||= begin
				values = "client_id=#{client_id(env)}&client_secret=#{client_secret(env)}"
				response = JSON.parse(RestClient.post("#{self.class.api_host}/token", values, { 'Content-Type': 'application/x-www-form-urlencoded' }))
				response["access_token"]
			end
		end
	end
end