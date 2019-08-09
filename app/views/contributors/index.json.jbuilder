json.set! :contributors do
	json.array! @contributors do |contributor|
		json.id contributor.id
		json.name contributor.display_name
		json.slug contributor.slug
		json.title contributor.title
		json.title contributor.title
		json.blurb contributor.blurb
		json.twitter_handle contributor.twitter_handle
		json.facebook_url contributor.facebook_url
		json.instagram_username contributor.instagram_username
		json.article_count contributor.article_count
		json.image contributor.image.url(:listing)
	end
end