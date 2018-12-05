ThinkingSphinx::Index.define :article, :with => :real_time do
  # fields
  indexes title
  indexes author.display_name, as: :author_name
  indexes strip_content, as: :content
  indexes publish_month, as: :published
  indexes exchange_names, as: :exchange_name
  indexes keyword_tags_names,  as: :tag_name

  # # attributes
  # has author_id,  :type => :integer
  # has created_at, :type => :timestamp
  # has updated_at, :type => :timestamp
end