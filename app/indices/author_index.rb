ThinkingSphinx::Index.define :author, :with => :real_time do
  indexes display_name
  indexes title
  indexes twitter_handle
  indexes blurb

  has article_count, type: :integer
end