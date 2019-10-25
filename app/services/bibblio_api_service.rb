module BibblioApiService
	class << self

		def create_user(user)
			begin
				raise Exception.new("User already on Bibblio!") if user.on_bibblio?
				data = user_data(user).to_json
				response = RestClient.post("#{api_host}/content-items", data, json_headers(Rails.env.to_sym))
				log("create_user", data, user, { status: :success })
				return true
			rescue RestClient::ExceptionWithResponse => e
				puts "ExceptionWithResponse #{e.message} #{user.id}\n"
				log("create_user", data, user, { status: :error, message: e.message })
				return false
			rescue Exception => e
				puts "Exception #{e.message} #{user.id}\n"
				log("create_user", data, user, { status: :error, message: e.message })
				return false
			end
		end

		def update_user(user, from_action)
			begin
				data = user_data(user, true).to_json
				response = RestClient.put("#{api_host}/content-items/#{user.id}", data, json_headers(Rails.env.to_sym))
				log("update_user - #{from_action}", data, user, { status: :success })
				return true
			rescue RestClient::ExceptionWithResponse => e
				puts "#{e.message} #{user.id}\n"
				log("update_user - #{from_action}", data, user, { status: :error, message: e.message })
				return false
			rescue Exception => e
				puts "#{e.message} #{user.id}\n"
				log("update_user - #{from_action}", data, user, { status: :error, message: e.message })
				return false
			end
		end

		def log(action, data, user, response)
			ApiLog.request({
				service: :bibblio,
				user_id: user.id,
				request_method: action,
				request_data: data,
				response: response
			})
		end

		def articles_catalog_id
			'538ee88d-c278-43ef-8391-6b9ebbe99f88'
		end

		def article_content_item_id(article)
			uri = "#{api_host}/content-items?page=1&catalogueId=#{articles_catalog_id}&customUniqueIdentifier=#{article.slug}"
			begin
				response = RestClient.get uri, json_headers(:production)
				results = JSON.parse(response)["results"]
				results[0]["contentItemId"]
			rescue Exception => e
				false
			end
		end

		def article_data(content_item_id)
			begin
				result = RestClient.get("#{api_host}/content-items/#{content_item_id}", json_headers(:production))
				JSON.parse(result)
			rescue Exception => e
				false
			end
		end

		def get_articles_meta(limit=10)
			articles = Article.where(has_bibblio_meta: false, remote_article_url: nil).where.not(slug: nil).limit(limit)
			puts "#{articles.length} articles found for processing...."
			updated = 0
			processed = 0
			articles.each do |article|
				if content_item_id = article_content_item_id(article)
					if data = article_data(content_item_id)
						if data["metadata"]
							concepts = []
							keywords = []
							entities = []
							data["metadata"]["keywords"].each do |keyword|
								keywords.push(keyword["text"]) if keyword["relevance"] >= 0.7
							end
							data["metadata"]["concepts"].each do |concept|
								concepts.push(concept["text"]) if concept["relevance"] >= 0.7
							end
							data["metadata"]["entities"].each do |entity|
								entities.push(entity["text"]) if entity["relevance"] >= 0.7
							end
							article.update_attribute(:meta_keywords, keywords.join(",")) if keywords.any?
							article.update_attribute(:meta_concepts, concepts.join(",")) if concepts.any?
							article.update_attribute(:meta_entities, entities.join(",")) if entities.any?
							updated += 1 if keywords.any? || concepts.any? || entities.any?
							sleep(2)
						end
					end
				end
				article.update_attribute(:has_bibblio_meta, true)
				processed += 1
			end
			puts "#{processed} articles processed."
			puts "#{updated} articles updated.\n"
			true
		end

		def api_host
			"https://api.bibblio.org/v1"
		end

		def user_catalog
			"Users"
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

		def article_url(article)
			article.remote_article_url.present? ? article.remote_article_url : "https://www.thearticle.com/#{article.slug}"
		end

		def access_token(env=:production)
			@access_token ||= begin
				values = "client_id=#{client_id(env)}&client_secret=#{client_secret(env)}"
				response = JSON.parse(RestClient.post("#{api_host}/token", values, { 'Content-Type': 'application/x-www-form-urlencoded' }))
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

		def user_data(user, with_keywords=false)
			exchanges = user.exchanges.map(&:name)
			user_data = {
			  customCatalogueId: user_catalog,
			  name: user.username,
	      url: "http://www.thearticle.com/profile/#{user.slug}",
	      text: user_info_as_text(user, exchanges),
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
			if with_keywords
				user_data[:keywords] = exchanges
			end
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