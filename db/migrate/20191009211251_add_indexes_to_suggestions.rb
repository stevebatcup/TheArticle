class AddIndexesToSuggestions < ActiveRecord::Migration[5.2]
  def change
    add_index :profile_suggestions, :user_id
    add_index :profile_suggestions, :reason
    add_index :profile_suggestions, :status
    add_index :profile_suggestions, :author_article_count
  end
end
