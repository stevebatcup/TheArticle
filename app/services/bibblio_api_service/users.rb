module BibblioApiService
	class Users < Base

		def initialize(user)
			@user = user
		end

		def create
			begin
				raise Exception.new("User already on Bibblio!") if @user.on_bibblio?
				url = "#{self.class.api_host}/content-items"
				response = RestClient.post(url, data.to_json, json_headers(Rails.env.to_sym))
				log("create_user", url, @user, { status: :success })
				return true
			rescue RestClient::ExceptionWithResponse => e
				puts "ExceptionWithResponse #{e.message} #{@user.id}\n"
				log("create_user", url, @user, { status: :error, message: e.message })
				return false
			rescue Exception => e
				puts "Exception #{e.message} #{@user.id}\n"
				log("create_user", url, @user, { status: :error, message: e.message })
				return false
			end
		end

		def update(from_action)
			begin
				url = "#{self.class.api_host}/content-items/#{@user.id}"
				response = RestClient.put(url, data(true).to_json, json_headers(Rails.env.to_sym))
				log("update_user - #{from_action}", url, @user, { status: :success })
				return true
			rescue RestClient::ExceptionWithResponse => e
				puts "#{e.message} #{@user.id}\n"
				log("update_user - #{from_action}", url, @user, { status: :error, message: e.message })
				return false
			rescue Exception => e
				puts "#{e.message} #{@user.id}\n"
				log("update_user - #{from_action}", url, @user, { status: :error, message: e.message })
				return false
			end
		end

		def info_as_text
			exchanges = @user.exchanges.map(&:name)
			data = [
				"joined on: #{@user.created_at.strftime("%d %b %Y")}",
				"location: '#{@user.location}'",
				"exchanges: '#{exchanges.join("', '")}'",
			]
			if @user.shares.any?
				ratings = @user.shares.where(share_type: 'rating')
				if ratings.any?
					ratings_urls = []
					ratings.each do |rating|
						ratings_urls << full_article_url(rating.article)
					end
					data << "ratings: '#{ratings_urls.join("', '")}'" if ratings_urls.any?
				end
			end
			data.join(", ")
		end

		def data(with_keywords=false)
			@data ||= begin
				exchanges = @user.exchanges.map(&:name)
				info = {
				  customCatalogueId: self.class.users_catalog,
				  name: @user.username,
		      text: info_as_text,
		      url: "http://www.thearticle.com/profile/#{@user.slug}",
	        customUniqueIdentifier: "#{@user.id}",
		      author: {
		      	name: @user.display_name.html_safe
		      },
		      dateCreated: @user.created_at.strftime("%Y-%m-%d\T%H:%M:%S.%L\Z"),
		      datePublished: @user.created_at.strftime("%Y-%m-%d\T%H:%M:%S.%L\Z"),
		      description: @user.bio.present? ? @user.bio : '',
		      headline: @user.display_name.html_safe,
		      learningResourceType: "encyclopedia article",
				}
				if with_keywords
					info[:keywords] = exchanges
				end
				if @user.cover_photo?
					info[:image] = {
						contentUrl: @user.cover_photo.url(:mobile)
					}
				end
				if @user.profile_photo?
					info[:moduleImage] = {
						contentUrl: @user.profile_photo.url(:square)
					}
					info[:thumbnail] = {
						contentUrl: @user.profile_photo.url(:square)
					}
				end
				info
			end
		end

		def self.users_catalog
			"Users"
		end

		def get_suggestions(limit=5, page=1)
			begin
				url = "#{self.class.api_host}/recommendations/related?customCatalogueIds=#{self.class.users_catalog}&customUniqueIdentifier=#{@user.id}&limit=#{limit}&page=#{page}"
				response = RestClient.get(url, json_headers(Rails.env.to_sym))
				log("get_recommendations_for_user", url, @user, { status: :success })
				items = JSON.parse(response)["results"]
				if items.any?
					usernames = []
					user_follow_ids = @user.followings.map(&:followed_id)
					items.each { |item| usernames << item["fields"]["name"] }
					users = User.where(username: usernames).where.not(id: user_follow_ids).to_a
					# puts users
					users
				else
					[]
				end
			rescue RestClient::ExceptionWithResponse => e
				puts "ExceptionWithResponse #{e.message} #{@user.id}\n"
				log("get_recommendations_for_user", url, @user, { status: :error, message: e.message })
				return false
			rescue Exception => e
				puts "Exception #{e.message} #{@user.id}\n"
				log("get_recommendations_for_user", url, @user, { status: :error, message: e.message })
				return false
			end

		end

	end
end