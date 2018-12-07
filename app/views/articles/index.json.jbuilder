if @error
	json.error @error
else
	json.set! :total, @total if @total
	json.set! :articles do
		json.array! @articles do |article|
			image_size = browser.device.mobile? ? :listing_mobile : :listing_desktop
			json.id article.id
			json.title strip_tags(article.title)
			json.excerpt article_excerpt_for_listing(article).html_safe
			json.path article_path(article)
			json.is_new article.is_newly_published?
			json.published_at article_date(article)
			json.image article.image.url(image_size) if article.image?
			json.author do
				author = article.author
				json.name author.display_name
				json.path contributor_path(slug: author.slug)
			end
			json.exchanges article.exchanges do |exchange|
				json.path exchange_badge_url(exchange)
				json.isSponsored exchange.slug == 'sponsored'
				json.name exchange.name
			end
		end
	end
end