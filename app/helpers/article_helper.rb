module ArticleHelper
	def article_author_url(article)
		contributor_path(slug: @article.author.slug)
	end

	def article_date(article)
		article.published_at.strftime("%d %b %Y").upcase
	end

	def article_excerpt_for_listing(article, length=130)
		truncate(article.excerpt, length: length, escape: false).html_safe
	end

	def article_path(article)
		"/#{article.slug}"
	end

	def adified_content(article)
		content_html =  Nokogiri::HTML.fragment(article.content)
		ad_slots = Article.content_ad_slots(request.variant.mobile?, ad_page_type, ad_page_id)
		ad_slots.each do |slot|
			ad_html = ActionController::Base.render(partial: 'layouts/ad', locals: slot)
			if position = content_html.css('p')[slot[:position]]
				position.before ad_html
			end
		end
		content_html.to_s.html_safe
	end
end