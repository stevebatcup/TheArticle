module Article::Adminable
  def self.included(base)
    base.extend ClassMethods
  end

  def admin_title
  	self.title.encode('utf-8', invalid: :replace, undef: :replace, replace: '').html_safe
  end

  def admin_author
    self.author.display_name.encode('utf-8', invalid: :replace, undef: :replace, replace: '').html_safe
  end

  def admin_exchange_list
  	self.exchanges.map(&:name).join(", ")
  end

  def admin_tag_list
  	self.keyword_tags.map(&:name).join(", ")
  end

  def admin_published_at
    self.published_at.strftime("%b %e, %Y")
  end

  def admin_share_count
    self.shares.length.to_s
  end

	module ClassMethods
	end
end