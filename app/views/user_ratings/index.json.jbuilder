json.total @total if @total
items = []
@ratings.each do |rating|
	items << share_as_json_data(@user, rating)
end
json.ratings items