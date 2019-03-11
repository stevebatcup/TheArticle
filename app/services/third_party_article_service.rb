require 'faraday'
require 'ogp'

module ThirdPartyArticleService
	class << self
		def scrape_url(url, current_user)
			standard_error_msg = "Unable to build preview"
			bad_url_error_msg = "Sorry we are not able to find details of an article at that URL"
			begin
				if url.include?('railstaging.thearticle.com')
					conn = Faraday.new('http://railstaging.thearticle.com')
					conn.basic_auth('londonbridge', 'B37ys0m2w')
					response = conn.get URI.parse(url).request_uri
				else
					conn = Faraday.new(nil, { ssl: { verify: false }})
					response = conn.get(url)
					response.body.force_encoding('utf-8')
				end
				OGP::OpenGraph.new(response.body)
			rescue Faraday::SSLError => e
				self::log_error(e, standard_error_msg, url, current_user)
				raise IOError.new("#{standard_error_msg}")
			rescue NoMethodError => e
				self::log_error(e, standard_error_msg, url, current_user)
				raise IOError.new("#{standard_error_msg}")
			rescue Faraday::ConnectionFailed, ArgumentError, URI::InvalidURIError => e
				self::log_error(e, bad_url_error_msg, url, current_user)
				raise IOError.new(bad_url_error_msg)
			rescue OGP::MissingAttributeError => e
				self::log_error(e, bad_url_error_msg, url, current_user)
				raise IOError.new(bad_url_error_msg)
			rescue Exception => e
				self::log_error(e, standard_error_msg, url, current_user)
				raise IOError.new("#{standard_error_msg}")
			end
		end

		def log_error(e, error_shown, url, current_user)
			ThirdPartyShareErrorLog.create({
				url: url,
				user_id: current_user.id,
				error_show_to_user: error_shown,
				exception_message: e.message
			})
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
			url.include?(current_host)
		end

		def create_from_share(params, current_user)
			host = self.get_domain_from_url(params[:url])
			if (!params[:article].empty?) && (WhiteListedThirdPartyPublisher.find_by(domain: host))
				# create the article
				article = self.create_article(params[:article])
				# create the share
				share = self.create_share(article.id, current_user, params[:post], params[:rating_well_written], params[:rating_valid_points], params[:rating_agree])
			else
				article_params = params[:article]
				if article_params.empty?
						article_params = {
						title: "No preview available",
						snippet: "Could not scrape preview of this article",
						image: nil
					}
				end
				create_quarantined_share(current_user, params[:url], params, article_params)
			end
		end

		def create_quarantined_share(current_user, url, params, article_params)
			QuarantinedThirdPartyShare.create({
				status: :pending,
				user_id: current_user.id,
				url: url,
				heading: article_params[:title],
				snippet: article_params[:snippet],
				image: article_params[:image],
				post: params[:post],
				rating_well_written: params[:rating_well_written],
				rating_valid_points: params[:rating_valid_points],
				rating_agree: params[:rating_agree]
			})
		end

		def create_article(article_params)
			Article.create({
				title: article_params[:title],
				content: "<p>#{article_params[:snippet]}</p>".html_safe,
				remote_article_url:  article_params[:url],
				remote_article_domain:  article_params[:domain],
				remote_article_image_url: article_params[:image],
				excerpt: "<p>#{article_params[:snippet]}</p>".html_safe,
				published_at: Time.now,
				robots_nofollow: 0,
				robots_noindex: 0
			})
		end

		def create_share(article_id, current_user, post, rating_well_written, rating_valid_points, rating_agree)
			rating_params = {
				rating_well_written: rating_well_written,
				rating_valid_points: rating_valid_points,
				rating_agree: rating_agree
			}
			Share.create({
				user_id: current_user.id,
				article_id: article_id,
				share_type: Share.determine_share_type(rating_params),
				post: post,
				rating_well_written: rating_well_written,
				rating_valid_points: rating_valid_points,
				rating_agree: rating_agree
			})
		end

		def approve_quarantined_share(quarantined_share)
			article = create_article({
				title: quarantined_share.heading,
				snippet: quarantined_share.snippet,
				url: quarantined_share.url,
				image: quarantined_share.image,
				domain: get_domain_from_url(quarantined_share.url)
			})
			create_share(article.id,
				User.find(quarantined_share.user_id),
				quarantined_share.post,
				quarantined_share.rating_well_written,
				quarantined_share.rating_valid_points,
				quarantined_share.rating_agree
			)
		end
	end
end
