module ArticleHelper
	def article_author_url(article)
		contributor_path(slug: @article.author.slug)
	end

	def article_date(article)
		article.published_at.strftime("%d %b %Y").upcase
	end

	def article_excerpt_for_listing(article, length=130)
		strip_tags(truncate(article.excerpt, length: length, escape: false).html_safe)
	end

	def article_path(article)
		article.remote_article_url.present? ? article.remote_article_url : "/#{article.slug}"
	end

	def adified_content(article)
		content_html =  Nokogiri::HTML.fragment(article.content)
		ad_slots = Article.content_ad_slots(request.variant.mobile?, ad_page_type, ad_page_id)
		ad_slots.each do |slot|
			ad_html = ActionController::Base.render(partial: 'common/ad', locals: slot)
			if position = content_html.css('p')[slot[:position]]
				position.before ad_html
			end
		end
		content_html.to_s.html_safe
	end

	def categorisation_as_json_data(user, categorisation)
		exchange = categorisation.exchange
		article = categorisation.article
		author = article.author
		{
			type: 'categorisation',
			stamp: categorisation.article.published_at.to_i,
			date: categorisation.article.published_at.strftime("%e %b"),
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
				exchange: {
					name: exchange.name,
					path: exchange_path(slug: exchange.slug),
					isSponsored: exchange.slug == 'sponsored',
				}
			}
		}
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