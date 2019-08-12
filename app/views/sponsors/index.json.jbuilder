json.set! :sponsors do
	json.array! @sponsors do |sponsor|
		json.id sponsor.id
		json.name sponsor.display_name
		json.slug sponsor.slug
		json.title sponsor.title
		json.title sponsor.title
		json.blurb sponsor.blurb
		json.twitter_handle sponsor.twitter_handle
		json.facebook_url sponsor.facebook_url
		json.instagram_username sponsor.instagram_username
		json.article_count sponsor.article_count
		json.image sponsor.image.url(:listing)
	end
end