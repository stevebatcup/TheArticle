if @ratings.any?
	json.set! :ratings do
		json.array! @ratings do |rating|
			json.wellWritten convert_rating_to_dots(rating.rating_well_written.to_i)
			json.wellWrittenText text_rating(:well_written, rating.rating_well_written)
			json.validPoints convert_rating_to_dots(rating.rating_valid_points.to_i)
			json.validPointsText text_rating(:valid_points, rating.rating_valid_points)
			json.agree convert_rating_to_dots(rating.rating_agree.to_i)
			json.agreeText text_rating(:agree, rating.rating_agree)
			json.date rating.created_at.strftime("%d %b %Y")
			json.post rating.post
			json.user do
				json.id rating.user.id
				json.displayName rating.user.display_name.html_safe
				json.username rating.user.username
				json.path profile_path(slug: rating.user.slug)
				json.profilePhoto rating.user.profile_photo.url(:square)
				json.coverPhoto rating.user.cover_photo.url(browser.device.mobile? ? :mobile : :desktop)
			end
		end
	end
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
			author = @article.author
			json.name author.display_name.html_safe
			json.path contributor_path(slug: author.slug)
		end
		json.exchanges @article.exchanges do |exchange|
			json.slug exchange.slug
			json.path exchange_badge_url(exchange)
			json.isSponsored exchange.slug == 'sponsored'
			json.name exchange.name
		end
		json.ratingWwc readable_article_rating(@article.ratings_well_written_cache)
		json.ratingVpc readable_article_rating(@article.ratings_valid_points_cache)
		json.ratingAc readable_article_rating(@article.ratings_agree_cache)
	end
end