ThinkingSphinx::Index.define :user, :with => :real_time do
	indexes display_name
  indexes username, :sortable => true
  indexes location
  indexes bio
  indexes status
  indexes has_completed_wizard
end