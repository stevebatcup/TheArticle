json.total @total if @total
items = []
@shares.each do |share|
	items << share_as_json_data(@user, share)
end
json.shares items