if @ratings.any?
	items = []
	@ratings.each do |rating|
		items << share_as_json_data(rating.user, rating)
	end
	json.ratings items
end

if @page == 1
	json.total @total
	json.article do
		image_size = browser.device.mobile? ? :cover_mobile : :listing_desktop
		json.id @article.id
		json.title strip_tags(@article.title)
		json.excerpt article_excerpt_for_listing(@article).html_safe
		json.path article_path(@article)
		json.isNew @article.is_newly_published?
		json.publishedAt article_date(@article)
		json.image @article.image.url(image_size) if @article.image?
		json.isSponsored @article.is_sponsored
		json.author do
			if author = @article.author
				json.name author.display_name.html_safe
				json.path contributor_path(slug: author.slug)
			end
		end
		json.exchanges @article.exchanges do |exchange|
			json.slug exchange.slug
			json.path exchange_badge_url(exchange)
			json.isSponsored exchange.slug == 'sponsored'
			json.name exchange.name
		end
		unless @article.additional_author.nil?
			json.additionalAuthor do
				json.name @article.additional_author.display_name
				json.path contributor_path(slug: @article.additional_author.slug)
			end
		end
		json.ratingAllWwc readable_article_rating(@article.ratings_well_written_cache)
		json.ratingAllVpc readable_article_rating(@article.ratings_valid_points_cache)
		json.ratingAllAc readable_article_rating(@article.ratings_agree_cache)

		followsRating = @article.get_follows_average_ratings(current_user)
		json.ratingFollowsWwc readable_article_rating(followsRating[:well_written])
		json.ratingFollowsVpc readable_article_rating(followsRating[:valid_points])
		json.ratingFollowsAc readable_article_rating(followsRating[:agree])
	end
end