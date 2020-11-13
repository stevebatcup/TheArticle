module ArticleHelper
	def article_author_url(article)
		contributor_path(slug: @article.author.slug)
	end

	def article_date(article, full_format=false)
		if full_format
			article.published_at.strftime("%A %B %d, %Y")
		else
			article.published_at.strftime("%d %b %Y").upcase
		end
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
			if link['href']
				unless link['href'].include?(host)
					link['target'] = '_blank'
					link['rel'] = 'noopener' # To avoid window.opener attack when target blank is used
				end
			end
		end
		content_html.to_s.html_safe
	end

	def adified_content(article)
		content_html =  Nokogiri::HTML.fragment(article.content)
		ad_slots = Article.content_ad_slots(article, request.variant.mobile?, ad_page_type, ad_page_id, ad_publisher_id, show_ads?, (show_ads? || show_video_ads_only?))

		ad_slots.each do |slot|
			ad_html = ActionController::Base.render(partial: 'common/ad', locals: slot)
			if position = content_html.css('p')[slot[:position]]
				position.before ad_html
			end
		end

		content_html.to_s.html_safe
	end

	def categorisation_as_json_data(user, article, exchanges)
		author = article.author
		result = {
			type: 'categorisation',
			stamp: article.published_at.to_i,
			date: event_date_formatted(article.published_at),
			article: {
				id: article.id,
				snippet: article_excerpt_for_listing(article, 160),
				image: article.image.url(:cover_mobile),
				title: article.title.html_safe,
				publishedAt: article_date(article),
				path: article_path(article),
				ratingCount: article.shares.where(share_type: 'rating').size,
				author: {
				  name: author.display_name,
				  path: contributor_path(slug: author.slug)
				},
				exchanges: []
			}
		}
		unless article.additional_author.nil?
			result[:article][:additionalAuthor] = {
			  name: article.additional_author.display_name,
			  path: contributor_path(slug: article.additional_author.slug)
			}
		end
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

	def registration_interstitial_cookie_expires
		24.hours.from_now
	end

	def show_registration_interstitial?
		min_views = Article.views_before_interstitial
		if !user_signed_in? && !cookies[:shown_registration_interstitial]
			if min_views == 0
				cookies[:shown_registration_interstitial] = { value: true, expires: registration_interstitial_cookie_expires }
				true
			elsif cookies[:seen_articles]
				val = cookies[:seen_articles].to_i
				if val == min_views
					cookies[:shown_registration_interstitial] = { value: true, expires: registration_interstitial_cookie_expires }
					cookies.delete(:seen_articles)
					true
				else
					new_val = val + 1
					cookies[:seen_articles] = { value: new_val, expires: registration_interstitial_cookie_expires }
					false
				end
			else
				cookies[:seen_articles] = { value: 1, expires: registration_interstitial_cookie_expires }
				false
			end
		end
	end

	def show_donation_interstitial?
		return false unless user_signed_in?

		donation = Donation.find_by(user_id: current_user.id)
		return false if donation && donation.recurring?

		time_gap = donation ? 1.month.ago : 7.days.ago
		last_impression = DonateInterstitialImpression.find_latest_for_user(current_user)

		if last_impression.nil?
			return true if !donation

			donation.created_at < time_gap
		else
			last_impression.shown_at < time_gap
		end
	end

	def written_by(article)
		tpl = article.additional_author.present? ? 'written-by-dual' : 'written-by-single'
		render partial: "articles/#{tpl}", locals: { article: article }
	end
end