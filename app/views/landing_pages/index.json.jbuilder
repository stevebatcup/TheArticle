json.array! @landing_pages do |landing_page|
	json.url "#{request.base_url}/#{landing_page.slug}"
	json.heading	landing_page.heading
end
