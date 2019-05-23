json.set! :results do
	json.array! @results do |result|
		json.id result.id
		json.name result.username
	end
end