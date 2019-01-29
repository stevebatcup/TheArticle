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

		def create_from_share(params)
			true
		end
	end
end
