require 'faraday'
require 'ogp'

module ThirdPartyArticleService
	class << self
		def scrape_url(url)
			begin
				response = Faraday.get(url)
				OGP::OpenGraph.new(response.body)
			rescue NoMethodError => e
				raise IOError.new("Sorry, we cannot properly read the data from that article URL")
			rescue Faraday::ConnectionFailed, ArgumentError
				raise IOError.new("Please enter a valid web URL")
			rescue OGP::MissingAttributeError
				raise IOError.new("Please enter a valid article URL")
			end
		end

		def create_from_share(params, current_user)
			url = params[:article][:url]
			host = URI.parse(url).host.downcase
			if WhiteListedThirdPartyPublisher.find_by(url: host)
				# create the article
				article = self.create_article(params[:article])
				# byebug
				# create the share
				self.create_share(article, params[:post], params[:rating_well_written], params[:rating_valid_points], params[:rating_agree])
			else
				QuarantinedThirdPartyShare.create({
					status: :pending,
					user_id: current_user.id,
					url: url,
					heading: params[:article][:title],
					snippet: params[:article][:snippet],
					image: params[:article][:image],
					post: params[:post],
					rating_well_written: params[:rating_well_written],
					rating_valid_points: params[:rating_valid_points],
					rating_agree: params[:rating_agree]
				})
			end
		end

		def create_article(article_params)
			Article.create({
				title: article_params[:title],
				content: "<p>#{article_params[:snippet]}</p>".html_safe,
				remote_article_url:  article_params[:url],
				remote_image_url: article_params[:image],
				excerpt: "<p>#{article_params[:snippet]}</p>".html_safe,
				published_at: Time.now,
				robots_nofollow: 0,
				robots_noindex: 0
			})
		end

		def create_share(article, post, rating_well_written, rating_valid_points, rating_agree)

		end
	end
end
