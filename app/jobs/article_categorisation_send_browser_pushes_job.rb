class ArticleCategorisationSendBrowserPushesJob < ApplicationJob
	queue_as :pushes

	include ActionView::Helpers::TextHelper
	include ActionView::Helpers::SanitizeHelper

	def perform(article)
		Categorisation.send_browser_pushes_for_article(article, excerpt_for_push(article))
	end

	def excerpt_for_push(article, length=120)
		strip_tags(truncate(article.excerpt, length: length, escape: false, separator: /\s/, omission: '...').html_safe)
	end
end
