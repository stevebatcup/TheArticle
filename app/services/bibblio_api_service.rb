module BibblioApiService
	class << self
		# include ActionView::Helpers::ArticleHelper

		def client_id
			@client_id ||= Rails.application.credentials.bibblio[:client_id]
		end

		def client_secret
			@client_secret ||= Rails.application.credentials.bibblio[:client_secret]
		end

		def access_token
			@access_token ||= begin
				values = "client_id=#{client_id}&client_secret=#{client_secret}"

				headers = {
					'Content-Type': 'application/x-www-form-urlencoded'
				}

				response = JSON.parse(RestClient.post('https://api.bibblio.org/v1/token', values, headers))
				response["access_token"]
			end
		end

		def user_info(user, exchanges)
			data = [
				"joined on: #{user.created_at.strftime("%d %b %Y")}",
				"location: '#{user.location}'",
				"exchanges: '#{exchanges}'",
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

		def create_user(user)
			begin
				raise Exception.new("User already on Bibblio!") if user.on_bibblio?
				exchanges = user.exchanges.map(&:name).join("', '")
				user_data = {
				  customCatalogueId: "Users",
				  name: user.username,
		      url: "http://www.thearticle.com/profile/#{user.slug}",
		      text: user_info(user, exchanges),
	        customUniqueIdentifier: "#{user.id}",
		      author: {
		      	name: user.display_name.html_safe
		      },
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

				headers = {
				  'Content-Type': 'application/json',
				  'Authorization': "Bearer #{access_token}"
				}

				response = RestClient.post('https://api.bibblio.org/v1/content-items', user_data.to_json, headers)
				true
			rescue RestClient::ExceptionWithResponse => e
				puts "#{e.message}\n"
				false
			rescue Exception => e
				puts "#{e.message}\n"
				false
			end
		end

		def article_url(article)
			article.remote_article_url.present? ? article.remote_article_url : "https://www.thearticle.com/#{article.slug}"
		end
	end

end