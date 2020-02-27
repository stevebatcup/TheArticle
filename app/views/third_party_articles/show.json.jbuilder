json.status @status
json.message @message if @message

if @article_open_graph
	json.set! :article do
		title = sanitize(@article_open_graph.title.encode('utf-8', invalid: :replace, undef: :replace, replace: ''))
		json.title truncate(title, length: 180)
		if title.length > 120
			description_length = 0
		elsif title.length > 60
			description_length = 75
		else
			description_length = 150
		end
		if description_length > 0 && @article_open_graph.description
			description = @article_open_graph.description.encode('utf-8', invalid: :replace, undef: :replace, replace: '')
			json.snippet truncate(sanitize(description), length: description_length)
		else
			json.snippet ''
		end
		json.type @article_open_graph.type
		image_url = @article_open_graph.image.url
		json.image image_url.include?("?") ? image_url.slice(0, image_url.index("?")) : image_url
		json.image image_url
		json.url @article_open_graph.url
		json.domain ThirdPartyArticleService.get_domain_from_url(@article_open_graph.url)
		json.siteName @article_open_graph.site_name
	end
end

if @previous_rated_article
	json.set! :previous_rated_article do
		share = @previous_rated_article.shares.first
		json.rating_well_written convert_rating_to_dots(share.rating_well_written)
		json.rating_valid_points convert_rating_to_dots(share.rating_valid_points)
		json.rating_agree convert_rating_to_dots(share.rating_agree)
		json.comments share.post
	end
end