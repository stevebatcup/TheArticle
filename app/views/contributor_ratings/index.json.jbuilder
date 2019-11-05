if @ratings.any?
	items = []
	@ratings.each do |rating|
		items << share_as_json_data(rating.user, rating)
	end
	json.ratings items
end