module SeoHelper
	def page_title(text)
    content_for :page_title, sanitize(text.html_safe)
  end

	def yield_page_title(default_text='')
    title = content_for?(:page_title) ? content_for(:page_title) : default_text
    "#{title} | TheArticle"
  end

  def meta_tag(tag, text)
    content_for :"meta_#{tag}", text
  end

  def yield_meta_tag(tag, default_text='')
    content_for?(:"meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end

  def page_og_type
  	'article' # website, profile
  end
end
