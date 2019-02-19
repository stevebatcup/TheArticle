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
			rescue Faraday::ConnectionFailed, ArgumentError, URI::InvalidURIError
				raise IOError.new("Please enter a valid web URL")
			rescue OGP::MissingAttributeError
				raise IOError.new("Please enter a valid article URL")
			end
		end

		def get_domain_from_url(url)
			URI.parse(url).host.downcase.gsub(/www\./, '')
		end

		def get_slug_from_url(url)
			URI.parse(url).request_uri.gsub("/", "")
		end

		def add_domain_from_url(url)
			host = self.get_domain_from_url(url)
			WhiteListedThirdPartyPublisher.create({domain: host})
		end

		def share_is_thearticle_domain(url, current_host)
			domain = get_domain_from_url(url)
			['thearticle.com', 'www.thearticle.com', current_host].include?(domain)
		end

		def create_from_share(params, current_user)
			url = params[:article][:url]
			host = self.get_domain_from_url(url)
			if WhiteListedThirdPartyPublisher.find_by(domain: host)
				# create the article
				article = self.create_article(params[:article])
				# create the share
				share = self.create_share(article.id, current_user, params[:post], params[:rating_well_written], params[:rating_valid_points], params[:rating_agree])
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
				remote_article_image_url: article_params[:image],
				excerpt: "<p>#{article_params[:snippet]}</p>".html_safe,
				published_at: Time.now,
				robots_nofollow: 0,
				robots_noindex: 0
			})
		end

		def create_share(article_id, current_user, post, rating_well_written, rating_valid_points, rating_agree)
			Share.create({
				user_id: current_user.id,
				article_id: article_id,
				post: post,
				rating_well_written: rating_well_written,
				rating_valid_points: rating_valid_points,
				rating_agree: rating_agree
			})
		end
	end
end
