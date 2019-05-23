class CategorisationsMailer < Devise::Mailer
  helper :application
	include Rails.application.routes.url_helpers
  include Devise::Controllers::UrlHelpers
  include ActionView::Helpers::TextHelper
  include MandrillMailer

  default(
    from: Rails.application.credentials.email_from,
    reply_to: Rails.application.credentials.email_reply_to
  )

  def as_it_happens(user, article, exchange)
    subject = "A new article has been added to the #{exchange.name} exchange"
    merge_vars = {
      FIRST_NAME: user.display_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      EXCHANGE_URL: exchange_url(slug: exchange.slug),
      EXCHANGE_NAME: exchange.name,
      ARTICLE_URL: article_url(slug: article.slug),
      ARTICLE_HTML: build_html([article])
    }
    body = mandrill_template("article-added-to-exchange-as-it-happens", merge_vars)
    send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body)
  end

  def daily(user, articles)
    subject = "Your daily update"
    merge_vars = {
      FIRST_NAME: user.display_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      ARTICLES_HTML: build_html(articles)
    }
    body = mandrill_template("article-added-to-exchange-daily", merge_vars)
    send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body)
  end

  def weekly(user, articles)
    subject = "Your weekly update"
    merge_vars = {
      FIRST_NAME: user.display_name,
      CURRENT_YEAR: Date.today.strftime("%Y"),
      ARTICLES_HTML: build_html(articles)
    }
    body = mandrill_template("article-added-to-exchange-weekly", merge_vars)
    send_mail(user.email, "#{user.first_name} #{user.last_name}", subject, body)
  end

  def build_html(articles)
  	html = "<table cellpadding='0' cellspacing='0' width='100%' style='width: 100%'>"
  	articles.each do |article|
  	  path = article_url(slug: article.slug)
  	  exchange = article.exchanges.first
  	  html << "
  	  <tr><td style='padding-bottom: 19px;'>
  	  	<table cellpadding='0' cellspacing='0' width='100%' style='width: 100%; text-align: left;'>
  	  		<tr>
  	  			<td>
  	  				<a href='#{path}' border='0' style='border: none;'>
  	  					<img src='#{article.image.url(:listing_desktop)}'
  	  							style='width: 100%; display: block;' alt='#{article.title.html_safe}' />
  	  				</a>
  	  			</td>
  	  		</tr>
  	  		<tr>
  	  			<td style='background-color: #efefef; padding-top: 10px; padding-right: 15px; padding-bottom: 0; padding-left: 15px; '>
		        	<a href='#{exchange_url(slug: exchange.slug)}'
		        			style='text-transform: uppercase;
											    color: white;
											    display: inline-block;
											    padding: 1px 15px 0 15px;
											    letter-spacing: 1.3px;
											    margin: 0 0 0;
											    font-size: 0.55em;
											    font-weight: 600;
											    position: relative;
											    top: -4px;
											    white-space: nowrap;
											    background-color: #6c00ac;
											    text-decoration: none;'>
								#{exchange.name}</a>
			        	<h2 class='text_shadow'
			        				style='color: #333;
													    margin-top: 10px;
													    margin-bottom: 10px;
													    line-height: 1.4;'>
			            <a href='#{path}' style='font-size: 25px; font-weight: bold; color: #333; text-decoration: none; background-color: transparent; border: none' border='0'>
			              #{article.title.html_safe}
			            </a>
			          </h2>

		        	<footer class='entry-footer' style='display: block; padding: 0; color: #333;'>
		        		<p class='author_link text_shadow'
		        					style='font-size: 11px;
		        								font-weight: 500;
		        								color: #999;
												    position: relative;
												    top: 9px;
												    margin-top: 0;
												    margin-bottom: 1rem;'>
		        			<a href='#{contributor_url(slug: article.author.slug)}' style='font-size: 11px; color: #333; text-decoration: none; background-color: transparent; border: none' border='0'>
		        				by <span style='font-size: 11px; text-decoration: underline; text-transform: uppercase; letter-spacing: 1px; text-decoration: none;'>#{article.author.display_name.html_safe}</span>
		        			</a> <span class='entry-date' style='font-size: 11px; color: #333; margin-left: 11px;'>#{article.published_at.strftime("%d %b %Y").upcase}</span></p>
		        	</footer>
	        	</td>
	      	</tr>
	      </table>
      </td></tr>"
  	end
  	html << '</table>'
  	html
  end
end
