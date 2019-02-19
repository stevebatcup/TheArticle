class AddRemoteArticleImageUrlToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :remote_article_image_url, :string, after: :remote_article_url
  end
end
