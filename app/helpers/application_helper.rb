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
end
