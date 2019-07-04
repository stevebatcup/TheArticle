module ArticleHelper
	def article_author_url(article)
		contributor_path(slug: @article.author.slug)
	end

	def article_date(article)
		article.published_at.strftime("%d %b %Y").upcase
	end

	def article_excerpt_for_listing(article, length=125)
		strip_tags(truncate(article.excerpt, length: length, escape: false, separator: /\s/, omission: ' [...]').html_safe)
	end

	def article_path(article)
		article.remote_article_url.present? ? article.remote_article_url : "/#{article.slug}"
	end

	def full_article_url(article)
		"#{request.base_url}/#{article.slug}"
	end

	def remote_linkify(content, host)
		content_html =  Nokogiri::HTML.fragment(content)
		# auto blankise remote links
		content_html.css('a').each do |link|
			unless link['href'].include?(host)
				link['target'] = '_blank'
				link['rel'] = 'noopener' # To avoid window.opener attack when target blank is used
			end
		end
		content_html.to_s.html_safe
	end

	def adified_content(article)
		content_html =  Nokogiri::HTML.fragment(article.content)
		ad_slots = Article.content_ad_slots(article, request.variant.mobile?, ad_page_type, ad_page_id, ad_publisher_id)

		ad_slots.each do |slot|
			ad_html = ActionController::Base.render(partial: 'common/ad', locals: slot)
			if position = content_html.css('p')[slot[:position]]
				position.before ad_html
			end
		end

		# # unruly video ads
		# if content_html.at_css('p')
		# 	if content_html.css('p')[3]
		# 		content_html.css('p')[3].before ActionController::Base.render(partial: 'common/unruly_script')
		# 	end
		# end

		content_html.to_s.html_safe
	end

	def categorisation_as_json_data(user, article, exchanges)
		author = article.author
		result = {
			type: 'categorisation',
			stamp: article.published_at.to_i,
			date: article.published_at.strftime("%e %b"),
			article: {
				id: article.id,
				snippet: article_excerpt_for_listing(article, 160),
				image: article.image.url(:cover_mobile),
				title: strip_tags(article.title),
				publishedAt: article_date(article),
				path: article_path(article),
				author: {
				  name: author.display_name,
				  path: contributor_path(slug: author.slug)
				},
				exchanges: []
			}
		}
		exchanges.each do |exchange|
			result[:article][:exchanges].push({
				name: exchange.name,
				path: exchange_path(slug: exchange.slug),
				isSponsored: exchange.slug == 'sponsored',
			})
		end
		result
	end

	def convert_rating_to_dots(rating)
		case rating
		when nil
			0
		when 0
			1
		when 25
			2
		when 50
			3
		when 75
			4
		when 100
			5
		else
			0
		end
	end

	def readable_article_rating(rating)
		if rating.nil? || rating == ''
			# browser.device.mobile? ? 'N/A' : "no ratings"
			'N/A'
		else
			"#{rating.to_i}%"
		end
	end
end