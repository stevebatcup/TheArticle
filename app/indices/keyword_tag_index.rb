ThinkingSphinx::Index.define :keyword_tag, :with => :real_time do
  indexes name

  has article_count, type: :integer
end