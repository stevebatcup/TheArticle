module Article::Adminable
  def self.included(base)
    base.extend ClassMethods
  end

  def admin_author
    return '' if self.author.nil?

    self.author.display_name.encode('utf-8', invalid: :replace, undef: :replace, replace: '').html_safe
  end

  def admin_exchange_list
    self.exchanges.collect do |ex|
      "<a href='/admin/exchanges/#{ex.id}'>#{ex.name}</a>"
    end.join(", ")
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

  def admin_rating_count
    self.shares.where(share_type: 'rating').length.to_s
  end

	module ClassMethods
	end
end