module BibblioApiService
	class Articles < Base

		def initialize(article)
			@stored_article = article
		end

		def data
			@data ||= begin
				log_action = "get_article - data"
				if content_item_id
					url = "#{self.class.api_host}/content-items/#{content_item_id}"
					result = RestClient.get(url, json_headers(:production))
					log(log_action, url, nil, { status: :success })
					JSON.parse(result)
				else
					false
				end
			rescue Exception => e
				log(log_action, url, nil, { status: :error, message: e.message })
				false
			end
		end

		def content_item_id
			@content_item_id ||= begin
				log_action = "get_article - content_item_id"
				url = "#{self.class.api_host}/content-items?page=1&catalogueId=#{self.class.articles_catalog_id}&customUniqueIdentifier=#{@stored_article.slug}"
				response = RestClient.get(url, json_headers(:production))
				log(log_action, url, nil, { status: :success })
				results = JSON.parse(response)["results"]
				results[0]["contentItemId"]
			rescue Exception => e
				log(log_action, url, nil, { status: :error, message: e.message })
				false
			end
		end

		def self.articles_catalog_id
			'538ee88d-c278-43ef-8391-6b9ebbe99f88'
		end

		def self.get_articles_meta(limit=10)
			articles = Article.where(has_bibblio_meta: false, remote_article_url: nil).where.not(slug: nil).limit(limit)
			puts "#{articles.length} articles found for processing...."
			updated = 0
			processed = 0
			articles.each do |article|
				bibblio_article = self.new(article)
				if bibblio_article.data && bibblio_article.data["metadata"]
					concepts = []
					keywords = []
					entities = []
					bibblio_article.data["metadata"]["keywords"].each do |keyword|
						keywords.push(keyword["text"]) if keyword["relevance"] >= 0.7
					end
					bibblio_article.data["metadata"]["concepts"].each do |concept|
						concepts.push(concept["text"]) if concept["relevance"] >= 0.7
					end
					bibblio_article.data["metadata"]["entities"].each do |entity|
						entities.push(entity["text"]) if entity["relevance"] >= 0.7
					end
					article.update_attribute(:meta_keywords, keywords.join(",")) if keywords.any?
					article.update_attribute(:meta_concepts, concepts.join(",")) if concepts.any?
					article.update_attribute(:meta_entities, entities.join(",")) if entities.any?
					updated += 1 if keywords.any? || concepts.any? || entities.any?
					sleep(1.5)
				end
				article.update_attribute(:has_bibblio_meta, true)
				processed += 1
			end
			puts "#{processed} articles processed."
			puts "#{updated} articles updated.\n"
			true
		end

	end
end