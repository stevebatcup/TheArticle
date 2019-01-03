ThinkingSphinx::Index.define :user, :with => :real_time do
	indexes display_name
  indexes username
  indexes location
  indexes bio
end