ThinkingSphinx::Index.define :share, :with => :real_time do
  indexes post
  # indexes comments

	has created_at, type: :timestamp

  scope { Share.includes(:article).references(:article).where("articles.author_id IS NOT NULL") }
end