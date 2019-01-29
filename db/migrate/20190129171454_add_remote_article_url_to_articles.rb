class AddRemoteArticleUrlToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :remote_article_url, :string, limit: 1000, after: :slug
  end
end
