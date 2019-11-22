if @exchange
	json.id @exchange.id
	json.name @exchange.name
	json.slug @exchange.slug
	json.description @exchange.description
	json.image @exchange.image.url(:listing)
	json.articleCount @exchange.article_count
	json.followerCount @exchange.follower_count
	json.isTrending @exchange.is_trending
else
	json.status :error
	json.message "Exchange not found"
end