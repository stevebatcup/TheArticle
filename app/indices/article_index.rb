ThinkingSphinx::Index.define :article, :with => :real_time do
  # fields
  indexes title
  indexes excerpt
  indexes keyword_tags_names,  as: :tag_name
  # indexes author.display_name, as: :author_name
  # indexes publish_month, as: :published
  # indexes exchange_names, as: :exchange_name

  # attributes
  has published_at, type: :timestamp
  # has author_id,  :type => :integer
  # has updated_at, :type => :timestamp

  scope { Article.where("author_id IS NOT NULL") }
end