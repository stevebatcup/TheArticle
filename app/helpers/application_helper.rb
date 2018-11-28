module ApplicationHelper
	def ga_tracking_id
		Rails.application.credentials.ga_tracking_id[Rails.env.to_sym]
	end

	def exchange_badge_url(exchange)
		exchange.slug == 'sponsored' ? '/sponsors' : exchange_path(slug: exchange.slug)
	end

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
end
