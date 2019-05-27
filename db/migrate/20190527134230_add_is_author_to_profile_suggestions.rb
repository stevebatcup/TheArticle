class AddIsAuthorToProfileSuggestions < ActiveRecord::Migration[5.2]
  def change
    add_column :profile_suggestions, :author_article_count, :integer, default: 0, after: :reason
  end
end
