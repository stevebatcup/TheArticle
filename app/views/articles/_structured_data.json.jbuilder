json.set! "@context", "http:\/\/schema.org"
json.set! "@type", "NewsArticle"
json.mainEntityOfPage do
	json.set! "@type", "NewsArticle"
	json.set! "@id", article_url(slug: article.slug)
end
json.headline "TheArticle"
json.url article_url(slug: article.slug)
json.thumbnailUrl article.image.url(:cover_desktop)
json.image do
	json.set! "@type", "ImageObject"
	json.url article.image.url(:cover_desktop)
end
json.dateCreated article.published_at.strftime("%Y-%m-%dT%H:%M:00Z")
json.datePublished article.published_at.strftime("%Y-%m-%dT%H:%M:00Z")
json.dateModified article.published_at.strftime("%Y-%m-%dT%H:%M:00Z")
json.articleSection "Uncategorised"
json.author do
	json.array! [article.author] do
		json.set! "@type", "Person"
		json.name article.author.display_name.html_safe
	end
end
json.set! :creator do
	json.array! [article.author.display_name.html_safe]
end
json.set! :keywords do
	json.array! article.keyword_tags.map(&:name)
end
json.publisher do
	json.set! "@type", "Organization"
	json.name "TheArticle"
	json.logo do
		json.set! "@type", "ImageObject"
		json.url
	end
end