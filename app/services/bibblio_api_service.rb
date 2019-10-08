module BibblioApiService
	class << self

		def create_user(user)
			begin
				raise Exception.new("User already on Bibblio!") if user.on_bibblio?
				# puts user_data(user).to_json
				response = RestClient.post("#{api_host}/content-items", user_data(user).to_json, headers)
				return true
			rescue RestClient::ExceptionWithResponse => e
				puts "ExceptionWithResponse #{e.message} #{user.id}\n"
				return false
			rescue Exception => e
				puts "Exception #{e.backtrace} #{e.message} #{user.id}\n"
				return false
			end
		end

		def update_user(user)
			begin
				response = RestClient.put("#{api_host}/content-items/#{user.id}", user_data(user).to_json, headers)
				return true
			rescue RestClient::ExceptionWithResponse => e
				puts "#{e.message} #{user.id}\n"
				return false
			rescue Exception => e
				puts "#{e.message} #{user.id}\n"
				return false
			end
		end

		def api_host
			"https://api.bibblio.org/v1"
		end

		def catalog
			if Rails.env.development?
				"TestUsers"
			else
				"Users"
			end
		end

		def client_id
			@client_id ||= Rails.application.credentials.bibblio[:client_id]
		end

		def client_secret
			@client_secret ||= Rails.application.credentials.bibblio[:client_secret]
		end

		def headers(content_type='application/json')
			{
			  'Content-Type': content_type,
			  'Authorization': "Bearer #{access_token}"
			}
		end

		def article_url(article)
			article.remote_article_url.present? ? article.remote_article_url : "https://www.thearticle.com/#{article.slug}"
		end

		def access_token
			@access_token ||= begin
				values = "client_id=#{client_id}&client_secret=#{client_secret}"
				response = JSON.parse(RestClient.post("#{api_host}/token", values, headers('application/x-www-form-urlencoded')))
				response["access_token"]
			end
		end

		def user_info_as_text(user, exchanges)
			data = [
				"joined on: #{user.created_at.strftime("%d %b %Y")}",
				"location: '#{user.location}'",
				"exchanges: '#{exchanges.join("', '")}'",
			]
			if user.shares.any?
				ratings = user.shares.where(share_type: 'rating')
				if ratings.any?
					ratings_urls = []
					ratings.each do |rating|
						ratings_urls << article_url(rating.article)
					end
					data << "ratings: '#{ratings_urls.join("', '")}'" if ratings_urls.any?
				end
			end
			data.join(", ")
		end

		def user_data(user)
			@user_data ||= begin
				exchanges = user.exchanges.map(&:name)
				user_data = {
				  customCatalogueId: catalog,
				  name: user.username,
		      url: "http://www.thearticle.com/profile/#{user.slug}",
		      text: user_info_as_text(user, exchanges),
	        customUniqueIdentifier: "#{user.id}",
		      author: {
		      	name: user.display_name.html_safe
		      },
		      keywords: "['" + exchanges.join("', '") + "']",
		      dateCreated: user.created_at.strftime("%Y-%m-%d\T%H:%M:%S.%L\Z"),
		      datePublished: user.created_at.strftime("%Y-%m-%d\T%H:%M:%S.%L\Z"),
		      description: user.bio,
		      headline: user.display_name.html_safe,
		      learningResourceType: "encyclopedia article",
				}
				if user.cover_photo?
					user_data[:image] = {
						contentUrl: user.cover_photo.url(:mobile)
					}
				end
				if user.profile_photo?
					user_data[:moduleImage] = {
						contentUrl: user.profile_photo.url(:square)
					}
					user_data[:thumbnail] = {
						contentUrl: user.profile_photo.url(:square)
					}
				end
				user_data
			end
		end
	end
end