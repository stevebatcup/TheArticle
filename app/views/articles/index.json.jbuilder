if @error
	json.error @error
else
	json.set! :total, @total if @total
	json.set! :articles do
		json.array! @articles do |article|
			image_size = browser.device.mobile? ? (@latest_for_feed ? :carousel : :cover_mobile) : :listing_desktop
			json.id article.id
			json.title article.title.html_safe
			json.excerpt article_excerpt_for_listing(article).html_safe
			json.path article_path(article)
			json.isNew article.is_newly_published?
			json.publishedAt article_date(article)
			json.image article.image.url(image_size) if article.image?
			json.isSponsored article.is_sponsored
			json.author do
				author = article.author
				json.name author.display_name.html_safe
				json.path contributor_path(slug: author.slug)
			end
			unless article.additional_author.nil?
				json.additionalAuthor do
					json.name article.additional_author.display_name
					json.path contributor_path(slug: article.additional_author.slug)
				end
			end
			exchanges = article.exchanges
			if article.additional_author.present? && exchanges.length > 2
				exchanges = exchanges.slice(0, 2)
			end
			json.exchanges exchanges do |exchange|
				json.slug exchange.slug
				json.path exchange_badge_url(exchange)
				json.isSponsored exchange.slug == 'sponsored'
				json.name exchange.name
			end
		end
	end
end