class AddFullArticleTermToSearchLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :search_logs, :full_article_term, :string, after: :term
  end
end
