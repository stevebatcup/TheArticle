base_url = "http://#{request.host_with_port}/"

xml.instruct! :xml, :version=>"1.0"
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9', 'xmlns:image' => 'http://www.google.com/schemas/sitemap-image/1.1', 'xmlns:video' => 'http://www.google.com/schemas/sitemap-video/1.1' do
	xml.url do
	  xml.loc base_url
	  xml.lastmod  Time.now.strftime("%Y-%m-%d")
	  xml.changefreq 'daily'
	  xml.priority 1.0
	end

  @articles.each do |article|
	  xml.url do
	    xml.loc base_url + article.slug
	    xml.lastmod  article.updated_at.strftime("%Y-%m-%d")
	    xml.changefreq 'monthly'
	    xml.priority 0.9
	  end
  end

  @exchanges.each do |exchange|
	  xml.url do
	    xml.loc "#{base_url}exchange/#{exchange.slug}"
	    xml.lastmod  exchange.updated_at.strftime("%Y-%m-%d")
	    xml.changefreq 'monthly'
	    xml.priority 0.8
	  end
  end

  @keyword_tags.each do |keyword_tag|
	  xml.url do
	    xml.loc "#{base_url}search?query=#{keyword_tag.slug}"
	    xml.lastmod  keyword_tag.updated_at.strftime("%Y-%m-%d")
	    xml.changefreq 'monthly'
	    xml.priority 0.7
	  end
  end

  @pages.each do |page|
	  xml.url do
	    xml.loc base_url + page.slug
	    xml.lastmod  page.updated_at.strftime("%Y-%m-%d")
	    xml.changefreq 'monthly'
	    xml.priority 0.6
	  end
  end

  @authors.each do |author|
	  xml.url do
	    xml.loc "#{base_url}contributor/#{author.slug}"
	    xml.lastmod  author.updated_at.strftime("%Y-%m-%d")
	    xml.changefreq 'monthly'
	    xml.priority 0.5
	  end
  end

  @sponsors.each do |sponsor|
	  xml.url do
	    xml.loc "#{base_url}sponsor/#{sponsor.slug}"
	    xml.lastmod  sponsor.updated_at.strftime("%Y-%m-%d")
	    xml.changefreq 'monthly'
	    xml.priority 0.5
	  end
  end
end