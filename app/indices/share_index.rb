ThinkingSphinx::Index.define :share, :with => :real_time do
  indexes post
  # indexes comments

  scope { Share.includes(:article).references(:article).where("articles.author_id IS NOT NULL") }
end