require "administrate/field/base"

class UrlField < Administrate::Field::Base
  def to_s
    data.to_s
  end

  def link
    options[:href].present? ? linkify(options[:href]) : to_s
  end

  def linkify(href)
    options[:append_id].present? ? "#{href}#{resource.id}" : href
  end

  def target
    options[:target] || "_blank"
  end
end
