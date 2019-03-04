class AddArticleCountToKeywordTags < ActiveRecord::Migration[5.2]
  def change
    add_column :keyword_tags, :article_count, :integer, default: 0
  end
end
